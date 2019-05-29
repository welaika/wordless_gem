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

    GLOBAL_NODE_MODULES = %w[foreman yarn].freeze

    def initialize(thor, options = {})
      @options = options
      @thor = thor
    end

    def start(name)
      install_global_node_modules
      install_wordpress_and_wp_cli(name)

      Dir.chdir(name)

      install_wordless
      create_and_activate_theme(name)
      set_permalinks

      Dir.chdir("wp-content/themes/#{name}")

      info("Installing theme's node modules...")
      run_command("yarn install") || error("Problem installing theme's node modules")

      success("All done! Now yor're ready to use Wordless with following commands:")
      info("`cd #{name}/wp-content/themes/#{name}`")
      info("`yarn run server`")
    end

    def install_wordless
      ensure_wp_cli_installed!

      info("Installing and activating plugin...")

      at_wordpress_root do
        github_url = 'https://github.com/welaika/wordless/archive/master.zip'
        error("Directory '#{plugins_path}' not found.") unless File.directory?(plugins_path)
        if run_command("wp plugin install #{github_url} --activate")
          success("Done!")
        else
          error("There was an error installing and/or activating the Wordless plugin.")
        end
      end
    end

    def install_global_node_modules
      info("Check for necessary global NPM packages")
      which('npm') ||
        error("Node isn't installed. Head to https://nodejs.org/en/download/package-manager")

      global_node_modules = GLOBAL_NODE_MODULES.dup

      global_node_modules.reject! do |m|
        run_command("npm list -g #{m}")
      end

      if global_node_modules.empty?
        success("Global NPM packages needed by Wordless already installed. Good job!")
        return true
      end

      global_node_modules.each do |m|
        run_command("npm install -g #{m}") && success("Installed NPM package #{m} globally")
      end
      success("Done!")
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

    def create_and_activate_theme(name)
      at_wordpress_root do
        info("Activating theme...")
        run_command("wp wordless theme create #{name}") || error("Cannot activate theme '#{name}'")
        success("Done!")
      end
    end

    def set_permalinks
      at_wordpress_root do
        info("Setting permalinks...")
        run_command('wp rewrite structure /%postname%/') || error("Cannot set permalinks")
        success("Done!")
      end
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end

      nil
    end
  end
end
