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

    DEFAULT_PATHS.each do |type, value|
      define_method "#{type}_path" do
        value
      end
    end

    def lib_dir
      @@lib_dir ||= File.expand_path(File.dirname(__FILE__))
    end

    def wordpress_dir(current_dir = start_dir)
      @wordpress_dir ||= (
        current_dir = File.expand_path(current_dir)

        if File.exist? File.join(current_dir, wp_content_path)
          current_dir
        elsif last_dir?(current_dir)
          raise StandardError, "Could not find a valid Wordpress directory"
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

    [ :say, :run ].each do |sym|
      define_method sym do |*args|
        thor.send(sym, *args)
      end
    end

    def initialize(options = {}, thor = nil)
      @options = options
      @thor = thor
    end

    def start(name)
      WordPressTools::CLI.new.invoke('new', [name], options.merge(wordpress_tools_options) )
      Dir.chdir(name)
      install
      theme(name)
    end

    def install
      at_wordpress_root!

      unless git_installed?
        error "Git is not available. Please install git."
      end

      if File.directory?(plugins_path)
        if run_command "git clone #{wordless_repo} #{wordless_plugin_path}"
          success "Installed Wordless plugin."
        else
          error "There was an error installing the Wordless plugin."
        end
      else
        error "Directory '#{plugins_path}' not found."
      end
    end

    def theme(name)
      at_wordpress_root!

      if File.directory?(themes_path)
        if system "php #{File.join(lib_dir, 'theme_builder.php')} #{name}"
          success "Created a new Wordless theme in '#{File.join(themes_path, name)}'."
        else
          error "Couldn't create Wordless theme."
        end
      else
        error "Directory '#{themes_path}' not found."
      end
    end

    def compile
      at_wordpress_root!

      if system "php #{File.join(lib_dir, 'compile_assets.php')}"
        success "Compiled static assets."
      else
        error "Couldn't compile static assets."
      end
    end

    def clean
      at_wordpress_root!

      if File.directory?(themes_path)
        static_css = Array(config[:static_css] || Dir['wp-content/themes/*/assets/stylesheets/screen.css'])
        static_js = Array(config[:static_js] || Dir['wp-content/themes/*/assets/javascripts/application.js'])

        (static_css + static_js).each do |file|
          FileUtils.rm_f(file) if File.exist?(file)
        end

        success "Cleaned static assets."
      else
        error "Directory '#{themes_path}' not found."
      end
    end

    def deploy
      at_wordpress_root!

      compile if options['refresh']

      deploy_command = options['command'].presence || config[:deploy_command]

      if deploy_command
        system "#{deploy_command}"
      else
        error "deploy_command not set. Make sure it is included in your Wordfile."
      end

      clean if options['refresh']
    end

    private

    def start_dir
      "."
    end

    def at_wordpress_root!
      Dir.chdir(wordpress_dir)
    end

    def wordless_plugin_path
      File.join(plugins_path, "wordless")
    end

    def wordless_repo
      config[:wordless_repo] || 'git://github.com/welaika/wordless.git'
    end

    def add_git_repo(repo, destination)
      run_command "git clone #{repo} #{destination}"
    end

    def wordpress_tools_options
      { bare: true }
    end

  end
end

