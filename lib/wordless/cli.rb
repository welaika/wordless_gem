module Wordless
  class CLI < Thor
    include Thor::Actions
    include WordPressTools::SharedOptions

    no_tasks do
      def wordless_cli
        Wordless::WordlessCLI.new(self, options)
      end
    end

    desc "new [NAME]", "Download WordPress in specified directory,
                        install the Wordless plugin and create a Wordless theme"
    add_method_options(shared_options)
    method_option :bare,
                  type: :boolean,
                  aliases: "-b",
                  desc: "Remove default themes and plugins",
                  default: true

    def new(name)
      wordless_cli.start(name)
    end
  end
end
