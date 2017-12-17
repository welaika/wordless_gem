require "spec_helper"

RSpec.describe Wordless::CLI do
  context "#new" do
    it "delegates call to wordless_cli" do
      expect_any_instance_of(Wordless::WordlessCLI).to receive(:start).with("myblog")
      described_class.start %w[new myblog]
    end
  end
end
