require 'spec_helper'

describe Wordless::WordlessCLI do
  let(:cli) { Wordless::WordlessCLI.new }

  context "#wordpress_dir" do
    TMPDIR = "/tmp/wordless"

    let(:wp_content) { File.join(TMPDIR, "wp-content") }

    before do
      @original_dir = Dir.pwd
      FileUtils.mkdir(TMPDIR)
      Dir.chdir(TMPDIR)
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(TMPDIR)
    end

    context "if a wordpress directory is found" do
      before do
        FileUtils.mkdir(wp_content)
      end

      it 'returns the directory' do
        expect(cli.wordpress_dir).to eq(File.expand_path("."))
      end
    end

    context "if no wordpress directory is found" do
      it 'raises an error' do
        expect { cli.wordpress_dir }.to raise_error(StandardError)
      end
    end

    context "directory traversal" do
      before do
        FileUtils.mkdir(wp_content)

        @test_dir = File.join(TMPDIR, "test")
        FileUtils.mkdir(@test_dir)
        Dir.chdir(@test_dir)
      end

      it 'goes up through the directory tree and finds it' do
        expect(cli.wordpress_dir).to eq(File.expand_path("./.."))
      end

    end
  end
end

