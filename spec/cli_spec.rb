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
    before :each do
      # Stub this way because otherwise Thor complains about a task without a desc
      module Wordless; class CLI; def wordless_repo; File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'wordless_stub')); end; end; end
    end
    
    context "with a valid WordPress installation" do
      it "installs the Wordless plugin" do
        Wordless::CLI.start ['wp']
        Dir.chdir 'wordpress'
        Wordless::CLI.start ['install']
        File.directory?('wp-content/plugins/wordless').should eq true
      end      
    end
    
    context "without a valid WordPress installation" do
      content = capture(:stdout) { Wordless::CLI.start ['install'] }
      content.should =~ %r|Directory 'wp-content/plugins' not found|
    end
  end
  
  after :each do
    Dir.chdir(@original_wd)
    %w(tmp/wordpress tmp/myapp).each do |dir|
      FileUtils.rm_rf(dir) if File.directory? dir
    end
  end
end