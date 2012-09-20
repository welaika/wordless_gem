require 'spec_helper'

describe Wordless::CLIHelper do

  before :each do
    @cli = Wordless::CLI.new
  end

  context "::download" do
    before(:each) do
      @tempfile = Tempfile.new("download_test")
      @valid_url = "http://www.example.com/test"
      FakeWeb.register_uri(:get, @valid_url, :body => "Download test")
    end

    it "downloads a file to the specified location" do
      @cli.download(@valid_url, @tempfile.path)
      open(@tempfile.path).read.should eq("Download test")
    end

    it "returns true on success" do
      @cli.download(@valid_url, @tempfile.path).should eq true
    end

    it "returns false on failure" do
      @cli.download("http://an.invalid.url", @tempfile.path).should eq false
    end

    after(:each) do
      @tempfile.close!
    end
  end

  context "::unzip" do
    it "unzips a file" do
      @cli.unzip(File.expand_path('spec/fixtures/zipped_file.zip'), 'tmp/unzip')
      File.exists?('tmp/unzip/zipped_file').should be true
    end

    after(:each) do
      FileUtils.rm_rf('tmp/unzip') if File.directory? 'tmp/unzip'
    end
  end

  context "::error" do
    it "displays an error" do
      $stdout.should_receive(:puts).with("\e[31mI am an error\e[0m")
      @cli.error("I am an error")
    end
  end

  context "::success" do
    it "displays a success message" do
      $stdout.should_receive(:puts).with("\e[32mI am a success message\e[0m")
      @cli.success("I am a success message")
    end
  end

  context "::warning" do
    it "displays a warning" do
      $stdout.should_receive(:puts).with("\e[33mI am a warning\e[0m")
      @cli.warning("I am a warning")
    end
  end
end
