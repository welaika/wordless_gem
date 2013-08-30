require 'spec_helper'

describe Wordless::CLI do

  before do
    Wordless::CLI.class_variable_set :@@config, {
      :wordless_repo => File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'wordless'))
    }
    @original_wd = Dir.pwd
    Dir.chdir('tmp')
  end

  after do
    Dir.chdir(@original_wd)
    Dir["tmp/*"].each do |dir|
      FileUtils.rm_rf(dir) if File.directory? dir
    end
  end

  context "#new" do
    it "downloads a copy of WordPress, installs Wordless and creates a theme" do
      Wordless::CLI.start ['new', 'myapp']
      File.exists?('wp-content/index.php').should be_true
      (File.exists?('wp-content/plugins/plugin.php') || File.directory?('wp-content/themes/theme')).should be_false
      File.directory?('wp-content/plugins/wordless').should be_true
      File.directory?('wp-content/themes/myapp').should be_true
      File.exists?('wp-content/themes/myapp/index.php').should be_true
    end
  end

  context "#install" do
    context "with a valid WordPress installation" do
      it "installs the Wordless plugin" do
        WordPressTools::CLI.start ['new']
        Dir.chdir 'wordpress'
        Wordless::CLI.start ['install']
        File.directory?('wp-content/plugins/wordless').should be_true
      end
    end

    context "without a valid WordPress installation" do
      it "fails to install the Wordless plugin" do
        content = capture(:stdout) { Wordless::CLI.start ['install'] }
        content.should =~ %r|Directory 'wp-content/plugins' not found|
      end
    end
  end

  context "#theme" do
    context "with a valid WordPress installation and the Wordless plugin" do
      before :each do
        WordPressTools::CLI.start ['new']
        Dir.chdir 'wordpress'
        Wordless::CLI.start ['install']
      end

      it "creates a Wordless theme" do
        Wordless::CLI.start ['theme', 'mytheme']
        File.directory?('wp-content/themes/mytheme').should be_true
        File.exists?('wp-content/themes/mytheme/index.php').should be_true
      end
    end

    context "without a valid WordPress installation" do
      it "fails to create a Wordless theme" do
        content = capture(:stdout) { Wordless::CLI.start ['theme', 'mytheme'] }
        content.should =~ %r|Directory 'wp-content/themes' not found|
      end
    end
  end

  context "#compile" do
    context "with a valid Wordless installation" do
      before :each do
        Wordless::CLI.start ['new', 'myapp']
      end

      it "compiles static assets" do
        Wordless::CLI.start ['compile']
        File.exists?('wp-content/themes/myapp/assets/stylesheets/screen.css').should be_true
        File.exists?('wp-content/themes/myapp/assets/javascripts/application.js').should be_true
      end
    end
  end

  context "#clean" do
    before do
      FileUtils.mkdir_p('myapp/wp-content/themes/myapp/assets/stylesheets')
      FileUtils.mkdir_p('myapp/wp-content/themes/myapp/assets/javascripts')
      Dir.chdir('myapp')
    end

    let(:default_css) { 'wp-content/themes/myapp/assets/stylesheets/screen.css' }
    let(:default_js) { 'wp-content/themes/myapp/assets/javascripts/application.js' }

    let(:first_css)  { 'wp-content/themes/myapp/assets/stylesheets/foo.css' }
    let(:second_css) { 'wp-content/themes/myapp/assets/stylesheets/bar.css' }
    let(:first_js)   { 'wp-content/themes/myapp/assets/javascripts/robin.js' }
    let(:second_js)  { 'wp-content/themes/myapp/assets/javascripts/galahad.js' }

    it "should remove default default assets" do
      FileUtils.touch(default_css)
      FileUtils.touch(default_js)

      Wordless::CLI.start ['clean']

      File.exists?(default_css).should be_false
      File.exists?(default_js).should be_false
    end

    it "should remove assets specified on config" do
      Wordless::CLI.class_variable_set :@@config, {
        :static_css => [ first_css, second_css ],
        :static_js =>  [ first_js, second_js ]
      }

      [ first_css, second_css, first_js, second_js ].each do |file|
        FileUtils.touch(file)
      end

      Wordless::CLI.start ['clean']

      [ first_css, second_css, first_js, second_js ].each do |file|
        File.exists?(file).should be_false
      end
    end
  end

  context "#deploy" do

    let(:cli)  { Wordless::CLI.new }
    let(:file) { 'shrubbery.txt' }

    before :each do
      FileUtils.mkdir_p('myapp') and Dir.chdir('myapp')
      FileUtils.touch('wp-config.php')
      Wordless::CLI.class_variable_set :@@config, {
        :deploy_command => "touch #{file}"
      }
    end

    it "should deploy via the deploy command" do
      cli.deploy
      File.exists?(file).should be_true
    end

    it "should compile and clean if refresh option is passed" do
      cli.should_receive(:compile).and_return(true)
      cli.should_receive(:clean).and_return(true)
      cli.stub(:options).and_return({ 'refresh' => true })
      cli.deploy
    end

    context "if a custom deploy is passed" do
      let(:file) { 'knights.txt' }

      it "should launch the custom deploy command" do
        cli.stub(:options).and_return({ 'command' => "touch #{file}" })
        cli.deploy
        File.exists?(file).should be_true
      end
    end
  end
end
