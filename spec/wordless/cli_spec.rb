require "spec_helper"

RSpec.describe Wordless::CLI do

  context "#new" do
    it "delegates call to wordless_cli" do
      expect_any_instance_of(Wordless::WordlessCLI).to receive(:start).with("myblog")
      described_class.start ['new', 'myblog']
    end
  end

  context "#install" do
    it "delegates call to wordless_cli" do
      expect_any_instance_of(Wordless::WordlessCLI).to receive(:install_wordless)
      described_class.start ['install']
    end
  end

  context "#theme" do
    it "delegates call to wordless_cli" do
      expect_any_instance_of(Wordless::WordlessCLI).to receive(:create_theme).with("mytheme")
      described_class.start ['theme', 'mytheme']
    end
  end

  context "#compile" do
    it "delegates call to wordless_cli" do
      expect_any_instance_of(Wordless::WordlessCLI).to receive(:compile)
      described_class.start ['compile']
    end
  end

  context "#clean" do
    it "delegates call to wordless_cli" do
      expect_any_instance_of(Wordless::WordlessCLI).to receive(:clean)
      described_class.start ['clean']
    end
  end

  context "#deploy" do
    it "delegates call to wordless_cli" do
      expect_any_instance_of(Wordless::WordlessCLI).to receive(:deploy)
      described_class.start ['deploy']
    end
  end
end

