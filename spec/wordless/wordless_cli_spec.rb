require 'spec_helper'

RSpec.describe Wordless::WordlessCLI do
  let(:cli_options) do {} end
  let(:wordless_cli) { described_class.new(Thor.new, cli_options) }

  before do
    allow(wordless_cli).to receive(:ensure_wp_cli_installed!).and_return(true)
  end

  context "without a valid wordpress folder" do
    it "fails and return a message" do
      in_wordpress_path do
        expect{ wordless_cli.install_wordless }.to raise_error(SystemExit)
        expect do
          begin
            wordless_cli.install_wordless
          rescue SystemExit
          end
        end.to output(%r|Could not find a valid Wordpress directory|).to_stdout
      end
    end
  end

  context "without a valid wordpress folders structure" do
    before do
      make_wpcontent_path!
    end

    it "fails to install the Wordless plugin" do
      in_wordpress_path do
        expect{ wordless_cli.install_wordless }.to raise_error(SystemExit)
        expect do
          begin
            wordless_cli.install_wordless
          rescue SystemExit
          end
        end.to output(%r|Directory 'wp-content/plugins' not found|).to_stdout
      end
    end

    it "fails to create a Wordless theme" do
      in_wordpress_path do
        expect{ wordless_cli.install_wordless }.to raise_error(SystemExit)
        expect do
          begin
            wordless_cli.create_theme("mytheme")
          rescue SystemExit
          end
        end.to output(%r|Directory 'wp-content/themes' not found|).to_stdout
      end
    end
  end

  context "installing wordless" do
    before { make_all_wordpress_paths! }

    it "installs the Wordless plugin" do
      in_wordpress_path do
        expect(wordless_cli).to receive(:run_command).with("wp plugin install wordless --activate").and_return(true)
        wordless_cli.install_wordless
      end
    end
  end

  context "#create_theme" do
    before do
      make_all_wordpress_paths!
      install_wordless!
    end

    it "creates a Wordless theme" do
      in_wordpress_path do
        wordless_cli.create_theme("mytheme")
        expect(File.directory?('wp-content/themes/mytheme')).to eq(true)
        expect(File.exist?('wp-content/themes/mytheme/index.php')).to eq(true)
      end
    end
  end

  context "#compile" do
    let(:compiled_css) { 'wp-content/themes/mytheme/assets/stylesheets/screen.css' }
    let(:compiled_js) { 'wp-content/themes/mytheme/assets/javascripts/application.js' }

    before do
      make_all_wordpress_paths!
      install_wordless!
      in_wordpress_path do
        wordless_cli.create_theme("mytheme")
      end
    end

    it "compiles static assets" do
      in_wordpress_path do
        wordless_cli.compile

        expect(File.exist?(compiled_css)).to eq(true)
        expect(File.exist?(compiled_js)).to eq(true)

        expect(File.readlines(compiled_css).grep(/html{line-height:1}/)).to_not be_empty
        expect(File.readlines(compiled_js).grep(/return "Yep, it works!";/)).to_not be_empty
      end
    end
  end

  context "#clean" do
    let(:default_css) { 'wp-content/themes/mytheme/assets/stylesheets/screen.css' }
    let(:default_js) { 'wp-content/themes/mytheme/assets/javascripts/application.js' }

    let(:first_css)  { 'wp-content/themes/mytheme/assets/stylesheets/foo.css' }
    let(:second_css) { 'wp-content/themes/mytheme/assets/stylesheets/bar.css' }
    let(:first_js)   { 'wp-content/themes/mytheme/assets/javascripts/robin.js' }
    let(:second_js)  { 'wp-content/themes/mytheme/assets/javascripts/galahad.js' }

    before do
      make_all_wordpress_paths!
      in_wordpress_path do
        FileUtils.mkdir_p('wp-content/themes/mytheme/assets/stylesheets')
        FileUtils.mkdir_p('wp-content/themes/mytheme/assets/javascripts')
      end
    end

    it "should remove default default assets" do
      in_wordpress_path do
        FileUtils.touch(default_css)
        FileUtils.touch(default_js)
        Wordless::WordlessCLI.class_variable_set :@@config, {}

        wordless_cli.clean

        expect(File.exist?(default_js)).to eq(false)
        expect(File.exist?(default_css)).to eq(false)
      end
    end

    it "should remove assets specified on config" do
      in_wordpress_path do
        Wordless::WordlessCLI.class_variable_set :@@config, {
          static_css: [ first_css, second_css ],
          static_js:  [ first_js, second_js ]
        }

        [ first_css, second_css, first_js, second_js ].each do |file|
          FileUtils.touch(file)
        end

        wordless_cli.clean

        [ first_css, second_css, first_js, second_js ].each do |file|
          expect(File.exist?(file)).to eq(false)
        end
      end
    end
  end

  context "#deploy" do
    let(:file) { 'shrubbery.txt' }

    before do
      make_all_wordpress_paths!
      Wordless::WordlessCLI.class_variable_set :@@config, {
        deploy_command: "touch #{file}"
      }
    end

    it "should deploy via the deploy command" do
      in_wordpress_path do
        wordless_cli.deploy
        expect(File.exist?(file)).to eq(true)
      end
    end

    context "refresh" do
      let(:cli_options) do { "refresh" => true } end

      it "should compile and clean if refresh option is passed" do
        in_wordpress_path do
          expect(wordless_cli).to receive(:compile).and_return(true)
          expect(wordless_cli).to receive(:clean).and_return(true)
          wordless_cli.deploy
        end
      end
    end

    context "custom deploy command" do
      let(:file) { 'knights.txt' }
      let(:options) do { "command" => "touch #{file}" } end

      it "should launch the custom deploy command" do
        in_wordpress_path do
          wordless_cli.deploy
          expect(File.exist?(file)).to eq(true)
        end
      end
    end
  end
end
