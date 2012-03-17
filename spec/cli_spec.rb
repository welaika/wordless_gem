require 'spec_helper'

describe Wordless::CLI do
  before :each do
    # $stdout = StringIO.new
    @original_wd = Dir.pwd
    wp_api_response = <<-eof
      upgrade
      http://wordpress.org/download/
      http://wordpress.org/wordpress-3.3.1.zip
      3.3.1
      en_US
      5.2.4
      5.0
    eof
    FakeWeb.register_uri(:get, %r|http://api.wordpress.org/core/version-check/1.5/.*|, :body => wp_api_response)
    FakeWeb.register_uri(:get, "http://wordpress.org/wordpress-3.3.1.zip", :body => File.expand_path('spec/fixtures/wordpress_stub.zip'))
    Dir.chdir('tmp')
  end
  
  context "#new" do
    it "downloads a copy of WordPress, installs Wordless and creates a theme" do
      Wordless::CLI.start ['new', 'myapp']
      File.exists?('wp-content/index.php').should eq true
      (File.exists?('wp-content/plugins/plugin.php') || File.directory?('wp-content/themes/theme')).should eq false
      File.directory?('wp-content/plugins/wordless').should eq true
      File.directory?('wp-content/themes/myapp').should eq true
      File.exists?('wp-content/themes/myapp/index.php').should eq true
    end
  end
  
  context "#wp" do
    context "with no arguments" do
      it "downloads a copy of WordPress" do
        Wordless::CLI.start ['wp']
        File.exists?('wordpress/wp-content/index.php').should eq true
      end

      it "initializes a git repository" do
        Wordless::CLI.start ['wp']
        File.directory?('wordpress/.git').should eq true
      end
      
      it "doesn't leave a stray 'wordpress' directory" do
        Wordless::CLI.start ['wp']
        File.directory?('wordpress/wordpress').should eq false
      end
    end
    
    context "with a custom directory name" do
      it "downloads a copy of WordPress in directory 'myapp'" do
        Wordless::CLI.start ['wp', 'myapp']
        File.exists?('myapp/wp-content/index.php').should eq true
      end
    end
    
    context "with the 'bare' option" do
      it "downloads a copy of WordPress and removes default plugins and themes" do
        Wordless::CLI.start ['wp', '--bare']
        (File.exists?('wordpress/wp-content/plugins/plugin.php') || File.directory?('wordpress/wp-content/themes/theme')).should eq false
      end
    end
  end
  
  context "#install" do
    context "with a valid WordPress installation" do
      it "installs the Wordless plugin" do
        Wordless::CLI.start ['wp']
        Dir.chdir 'wordpress'
        Wordless::CLI.start ['install']
        File.directory?('wp-content/plugins/wordless').should eq true
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
        Wordless::CLI.start ['wp']
        Dir.chdir 'wordpress'
        Wordless::CLI.start ['install']
      end
      
      it "creates a Wordless theme" do
        Wordless::CLI.start ['theme', 'mytheme']
        File.directory?('wp-content/themes/mytheme').should eq true
        File.exists?('wp-content/themes/mytheme/index.php').should eq true
      end
    end
    
    context "without a valid WordPress installation" do
      it "fails to create a Wordless theme" do
        content = capture(:stdout) { Wordless::CLI.start ['theme', 'mytheme'] }
        content.should =~ %r|Directory 'wp-content/themes' not found|
      end
    end
  end
  
  after :each do
    Dir.chdir(@original_wd)
    %w(tmp/wordpress tmp/myapp).each do |dir|
      FileUtils.rm_rf(dir) if File.directory? dir
    end
  end
end