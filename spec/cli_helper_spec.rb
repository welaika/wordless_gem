require 'spec_helper'
require 'fakeweb'

describe Wordless::CLIHelper do
  context "::download" do
    before(:each) do
      @tempfile = Tempfile.new("download_test")
    end
    
    it "downloads a file to the specified location" do
      FakeWeb.register_uri(:get, "http://www.example.com/test", :body => "Download test")
      Wordless::CLIHelper.download("http://www.example.com/test", @tempfile.path)
      open(@tempfile.path).read.should eq("Download test")
    end
    
    after(:each) do
      @tempfile.close!
    end
  end
  
  context "::unzip" do
    it "unzips a file" do
      Wordless::CLIHelper.unzip(File.expand_path('spec/support/zipped_file.zip'), 'tmp/unzip')
      File.exists?('tmp/unzip/zipped_file').should be true
    end
    
    after(:each) do
      File.delete('tmp/unzip/zipped_file') if File.exists? 'tmp/unzip/zipped_file'
    end
  end
end