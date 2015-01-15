require 'thor'
require 'spec_helper'

describe Wordless::CLI do

  let(:config) do
    { :wordless_repo => File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'wordless')) }
  end

  before do
    Wordless::WordlessCLI.class_variable_set(:@@config, config)
  end

  before do
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
      File.exist?('wp-content/index.php').should be_true
      (File.exist?('wp-content/plugins/plugin.php') || File.directory?('wp-content/themes/theme')).should be_false
      File.directory?('wp-content/plugins/wordless').should be_true
      File.directory?('wp-content/themes/myapp').should be_true
      File.exist?('wp-content/themes/myapp/index.php').should be_true
    end
  end

  context "without a valid WordPress install" do
    before do
      FileUtils.mkdir_p('wordpress/wp-content') && Dir.chdir('wordpress')
    end

    it "fails to install the Wordless plugin" do
      content = capture(:stdout) { Wordless::CLI.start ['install'] }
      content.should =~ %r|Directory 'wp-content/plugins' not found|
    end

    it "fails to create a Wordless theme" do
      content = capture(:stdout) { Wordless::CLI.start ['theme', 'mytheme'] }
      content.should =~ %r|Directory 'wp-content/themes' not found|
    end
  end

  context "#install" do
    before do
      WordPressTools::CLI.start ['new']
      Dir.chdir 'wordpress'
    end

    it "installs the Wordless plugin" do
      Wordless::CLI.start ['install']
      File.directory?('wp-content/plugins/wordless').should be_true
    end
  end

  context "#theme" do
    before do
      WordPressTools::CLI.start ['new']
      Dir.chdir 'wordpress'
      Wordless::CLI.start ['install']
    end

    it "creates a Wordless theme" do
      Wordless::CLI.start ['theme', 'mytheme']
      File.directory?('wp-content/themes/mytheme').should be_true
      File.exist?('wp-content/themes/mytheme/index.php').should be_true
    end
  end

  context "with a working Wordless install" do
    before do
      Wordless::CLI.start ['new', 'myapp']
    end

    context "#compile" do
      let(:compiled_css) { 'wp-content/themes/myapp/assets/stylesheets/screen.css' }
      let(:compiled_js) { 'wp-content/themes/myapp/assets/javascripts/application.js' }

      it "compiles static assets" do
        Wordless::CLI.start ['compile']

        File.exist?(compiled_css).should be_true
        File.exist?(compiled_js).should be_true

        File.readlines(compiled_css).grep(/html{line-height:1}/).should_not be_empty
        File.readlines(compiled_js).grep(/return "Yep, it works!";/).should_not be_empty
      end
    end

    context "#clean" do
      before do
        FileUtils.mkdir_p('wp-content/themes/myapp/assets/stylesheets')
        FileUtils.mkdir_p('wp-content/themes/myapp/assets/javascripts')
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

        File.exist?(default_css).should be_false
        File.exist?(default_js).should be_false
      end

      it "should remove assets specified on config" do
        Wordless::WordlessCLI.class_variable_set :@@config, {
          :static_css => [ first_css, second_css ],
          :static_js =>  [ first_js, second_js ]
        }

        [ first_css, second_css, first_js, second_js ].each do |file|
          FileUtils.touch(file)
        end

        Wordless::CLI.start ['clean']

        [ first_css, second_css, first_js, second_js ].each do |file|
          File.exist?(file).should be_false
        end
      end
    end

    context "#deploy" do
      let(:cli)  { Wordless::CLI.new }
      let(:file) { 'shrubbery.txt' }
      let(:wordless_cli)  { Wordless::WordlessCLI.new({}, Thor.new) }

      before do
        cli.stub(:wordless_cli).and_return(wordless_cli)
        Wordless::WordlessCLI.class_variable_set :@@config, {
          :deploy_command => "touch #{file}"
        }
      end

      it "should deploy via the deploy command" do
        cli.deploy
        File.exist?(file).should be_true
      end

      it "should compile and clean if refresh option is passed" do
        wordless_cli.should_receive(:compile).and_return(true)
        wordless_cli.should_receive(:clean).and_return(true)
        wordless_cli.stub(:options).and_return({ 'refresh' => true })

        cli.deploy
      end

      context "if a custom deploy is passed" do
        let(:file) { 'knights.txt' }

        it "should launch the custom deploy command" do
          wordless_cli.stub(:options).and_return({ 'command' => "touch #{file}" })
          cli.deploy
          File.exist?(file).should be_true
        end
      end
    end
  end

end
