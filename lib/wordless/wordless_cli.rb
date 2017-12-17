module Wordless
  class WordlessCLI
    include CLIHelper

    attr_reader :options, :thor

    module PATH
      WORDFILE   = :wordfile
      WP_CONTENT = :wp_content
      PLUGINS    = :plugins
      THEMES     = :themes
    end

    DEFAULT_PATHS = {
      PATH::WORDFILE   => 'Wordfile',
      PATH::WP_CONTENT => 'wp-content',
      PATH::PLUGINS    => 'wp-content/plugins',
      PATH::THEMES     => 'wp-content/themes'
    }.freeze

    def initialize(thor, options = {})
      @options = options
      @thor = thor
    end

    def start(name)
      install_wordpress_and_wp_cli(name)

      Dir.chdir(name)

      install_wordless
      create_theme(name)
      activate_theme(name)
      set_permalinks
    end

    def install_wordless
      ensure_wp_cli_installed!

      info("Installing and activating plugin...")

      at_wordpress_root do
        error("Directory '#{plugins_path}' not found.") unless File.directory?(plugins_path)
        if run_command("wp plugin install wordless --activate")
          success("Done!")
        else
          error("There was an error installing and/or activating the Wordless plugin.")
        end
      end
    end

    private

    DEFAULT_PATHS.each do |type, value|
      define_method "#{type}_path" do
        value
      end
    end

    def lib_dir
      @lib_dir ||= __dir__
    end

    def wordpress_dir(current_dir = Dir.pwd)
      @wordpress_dir ||= begin
        current_dir = File.expand_path(current_dir)

        if File.exist?(File.join(current_dir, wp_content_path))
          current_dir
        elsif last_dir?(current_dir)
          error("Could not find a valid Wordpress directory")
        else
          wordpress_dir(upper_dir(current_dir))
        end
      end
    end

    def last_dir?(directory)
      directory == "/"
    end

    def upper_dir(directory)
      File.join(directory, '..')
    end

    def config
      @config ||= begin
        if File.exist?(wordfile_path)
          YAML.safe_load(File.open(wordfile_path)).symbolize_keys
        else
          {}
        end
      end
    end

    def at_wordpress_root
      pwd = Dir.pwd
      Dir.chdir(wordpress_dir)
      begin
        yield
      ensure
        Dir.chdir(pwd)
      end
    end

    def install_wordpress_and_wp_cli(name)
      WordPressTools::CLI.new.invoke('new', [name], options)
    end

    def activate_theme(name)
      at_wordpress_root do
        info("Activating theme...")
        run_command("wp theme activate #{name}") || error("Cannot activate theme '#{name}'")
        success("Done!")
      end
    end

    def set_permalinks
      at_wordpress_root do
        info("Setting permalinks for wordless...")
        run_command('wp rewrite structure /%postname%/') || error("Cannot set permalinks")
        success("Done!")
      end
    end
  end
end
