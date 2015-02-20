module Wordless
  class CLI < Thor
    include Thor::Actions
    include WordPressTools::SharedOptions

    no_tasks do
      def wordless_cli
        Wordless::WordlessCLI.new(options, self)
      end
    end

    desc "new [NAME]", "Download WordPress in specified directory, install the Wordless plugin and create a Wordless theme"
    add_method_options(shared_options)
    method_option :bare, type: :boolean, aliases: "-b", desc: "Remove default themes and plugins", default: true
    def new(name)
      wordless_cli.start(name)
    end

    desc "install", "Install the Wordless plugin into an existing WordPress installation"
    def install
      wordless_cli.install
    end

    desc "theme [NAME]", "Create a new Wordless theme NAME"
    def theme(name)
      wordless_cli.create_theme(name)
    end

    desc "compile", "Compile static assets"
    def compile
      wordless_cli.compile
    end

    desc "clean", "Clean static assets"
    def clean
      wordless_cli.clean
    end

    desc "deploy", "Deploy your WordPress site using the deploy_command defined in your Wordfile"
    method_option :refresh, :aliases => "-r", :desc => "Compile static assets before deploying and clean them afterwards"
    method_option :command, :aliases => "-c", :desc => "Use a custom deploy command"
    def deploy
      wordless_cli.deploy
    end
  end
end

