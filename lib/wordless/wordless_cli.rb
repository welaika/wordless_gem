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
      PATH::THEMES     => 'wp-content/themes',
    }

    def initialize(thor, options = {})
      @options = options
      @thor = thor
    end

    def start(name)
      install_wordpress_and_wp_cli(name)
      ensure_wp_cli_installed!

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

    def create_theme(name)
      at_wordpress_root do
        if File.directory?(themes_path)
          if run_command("php #{File.join(lib_dir, 'theme_builder.php')} #{name}")
            success("Created a new Wordless theme in '#{File.join(themes_path, name)}'.")
          else
            error("Couldn't create Wordless theme.")
          end
        else
          error("Directory '#{themes_path}' not found.")
        end
      end
    end

    def compile
      at_wordpress_root do
        if system "php #{File.join(lib_dir, 'compile_assets.php')}"
          success("Compiled static assets.")
        else
          error("Couldn't compile static assets.")
        end
      end
    end

    def clean
      at_wordpress_root do
        if File.directory?(themes_path)
          static_css = Array(config[:static_css] || Dir['wp-content/themes/*/assets/stylesheets/screen.css'])
          static_js = Array(config[:static_js] || Dir['wp-content/themes/*/assets/javascripts/application.js'])

          (static_css + static_js).each do |file|
            FileUtils.rm_f(file) if File.exist?(file)
          end

          success("Cleaned static assets.")
        else
          error("Directory '#{themes_path}' not found.")
        end
      end
    end

    def deploy
      at_wordpress_root do
        compile if options['refresh']

        deploy_command = options['command'].presence || config[:deploy_command]

        if deploy_command
          system("#{deploy_command}")
        else
          error("deploy_command not set. Make sure it is included in your Wordfile.")
        end

        clean if options['refresh']
      end
    end

    private

    DEFAULT_PATHS.each do |type, value|
      define_method "#{type}_path" do
        value
      end
    end

    def lib_dir
      @@lib_dir ||= File.expand_path(File.dirname(__FILE__))
    end

    def wordpress_dir(current_dir = Dir.pwd)
      @wordpress_dir ||= (
        current_dir = File.expand_path(current_dir)

        if File.exist?(File.join(current_dir, wp_content_path))
          current_dir
        elsif last_dir?(current_dir)
          error("Could not find a valid Wordpress directory")
        else
          wordpress_dir(upper_dir(current_dir))
        end
      )
    end

    def last_dir?(directory)
      directory == "/"
    end

    def upper_dir(directory)
      File.join(directory, '..')
    end

    def config
      @@config ||= (
        if File.exist?(wordfile_path)
          YAML::load(File.open(wordfile_path)).symbolize_keys
        else
          {}
        end
      )
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
        run_command("wp rewrite structure /%postname%/") || error("Cannot set permalinks")
        success("Done!")
      end
    end
  end
end
