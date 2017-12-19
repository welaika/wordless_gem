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

  context "#install_global_node_modules" do
    it "stops execution if node is not installed" do
      allow_any_instance_of(Wordless::CLIHelper)
        .to receive(:run_command)
        .with("which npm")
        .and_return(false)

      expect do
        begin
          wordless_cli.start('test')
        rescue SystemExit
        end
      end
        .to output(%r{Node isn't installed. Head to https://nodejs.org/en/download/package-manager})
        .to_stdout
    end

    it "checks if global node modules are already installed" do
      allow_any_instance_of(Wordless::CLIHelper)
        .to receive(:run_command)
        .with("which npm")
        .and_return(true)
      described_class::GLOBAL_NODE_MODULES.each do |m|
        allow_any_instance_of(Wordless::CLIHelper)
          .to receive(:run_command)
          .with("npm list -g #{m}")
          .and_return(true)
      end

      expect { wordless_cli.install_global_node_modules }
        .to output(/Global NPM packages needed by Wordless already installed. Good job!/)
        .to_stdout
    end

    it "installs global node modules it they are not already" do
      allow_any_instance_of(Wordless::CLIHelper)
        .to receive(:run_command)
        .with("which npm")
        .and_return(true)
      allow_any_instance_of(Wordless::CLIHelper)
        .to receive(:run_command)
        .with("npm list -g foreman")
        .and_return(true)
      allow_any_instance_of(Wordless::CLIHelper)
        .to receive(:run_command)
        .with("npm list -g yarn")
        .and_return(false)
      allow_any_instance_of(Wordless::CLIHelper)
        .to receive(:run_command)
        .with("npm install -g yarn")
        .and_return(true)

      expect { wordless_cli.install_global_node_modules }
        .to output(/Installed NPM package yarn globally/)
        .to_stdout
    end
  end
end
