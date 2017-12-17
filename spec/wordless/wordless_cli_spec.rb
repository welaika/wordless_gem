require 'spec_helper'

RSpec.describe Wordless::WordlessCLI do
  let(:cli_options) { {} }
  let(:wordless_cli) { described_class.new(Thor.new, cli_options) }

  before do
    allow(wordless_cli).to receive(:ensure_wp_cli_installed!).and_return(true)
  end

  context "without a valid wordpress folder" do
    it "fails and return a message" do
      in_wordpress_path do
        expect { wordless_cli.install_wordless }.to raise_error(SystemExit)
        expect do
          begin
            wordless_cli.install_wordless
          rescue SystemExit
          end
        end.to output(/Could not find a valid Wordpress directory/).to_stdout
      end
    end
  end

  context "without a valid wordpress folders structure" do
    before do
      make_wpcontent_path!
    end

    it "fails to install the Wordless plugin" do
      in_wordpress_path do
        expect { wordless_cli.install_wordless }.to raise_error(SystemExit)
        expect do
          begin
            wordless_cli.install_wordless
          rescue SystemExit
          end
        end.to output(%r{Directory 'wp-content/plugins' not found}).to_stdout
      end
    end
  end

  context "installing wordless" do
    before { make_all_wordpress_paths! }

    it "installs the Wordless plugin" do
      in_wordpress_path do
        expect(wordless_cli)
          .to receive(:run_command)
          .with("wp plugin install wordless --activate")
          .and_return(true)
        wordless_cli.install_wordless
      end
    end
  end
end
