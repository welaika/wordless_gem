require 'spec_helper'

describe Wordless::CLI do
  before :each do
    # $stdout = StringIO.new
  end
  
  context "#wp" do
    before(:each) do
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
      @original_wd = Dir.pwd
      Dir.chdir('tmp')
    end
    
    context "with default arguments" do
      it "downloads a copy of WordPress" do
        Wordless::CLI.start(['wp'])
        File.exists?('wordpress/wp-content/index.php').should eq true
      end

      it "initializes a git repository" do
        Wordless::CLI.start(['wp'])
        File.directory?('wordpress/.git').should eq true
      end
    end
    
    after :each do
      FileUtils.rm_rf('wordpress') if File.directory? 'wordpress'
      Dir.chdir(@original_wd)
    end
  end
end