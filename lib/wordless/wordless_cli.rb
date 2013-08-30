require 'wordpress_tools/cli'

module Wordless
  class WordlessCLI
    include WordPressTools::CLIHelper
    attr_reader :options, :thor

    def lib_dir
      @@lib_dir ||= File.expand_path(File.dirname(__FILE__))
    end

    def config
      @@config ||= (
        if File.exists?('Wordfile')
          YAML::load(File.open('Wordfile')).symbolize_keys
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
      WordPressTools::CLI.new.invoke('new', [name], :bare => true, :locale => options['locale'])
      Dir.chdir(name)
      install
      theme(name)
    end

    def install
      unless git_installed?
        error "Git is not available. Please install git."
      end

      unless File.directory? 'wp-content/plugins'
        error "Directory 'wp-content/plugins' not found. Make sure you're at the root level of a WordPress installation."
      end

      if run_command "git clone #{wordless_repo} wp-content/plugins/wordless"
        success "Installed Wordless plugin."
      else
        error "There was an error installing the Wordless plugin."
      end
    end

    def theme(name)
      if File.directory? 'wp-content/themes'
        # Run PHP helper script
        if system "php #{File.join(lib_dir, 'theme_builder.php')} #{name}"
          success "Created a new Wordless theme in 'wp-content/themes/#{name}'."
        else
          error "Couldn't create Wordless theme."
        end
      else
        error "Directory 'wp-content/themes' not found. Make sure you're at the root level of a WordPress installation."
      end
    end

    def compile
      if system "php #{File.join(lib_dir, 'compile_assets.php')}"
        success "Compiled static assets."
      else
        error "Couldn't compile static assets."
      end
    end

    def clean
      if File.directory? 'wp-content/themes'
        static_css = Array(config[:static_css] || Dir['wp-content/themes/*/assets/stylesheets/screen.css'])
        static_js = Array(config[:static_js] || Dir['wp-content/themes/*/assets/javascripts/application.js'])

        (static_css + static_js).each do |file|
          FileUtils.rm_f(file) if File.exists?(file)
        end

        success "Cleaned static assets."
      else
        error "Directory 'wp-content/themes' not found. Make sure you're at the root level of a WordPress installation."
      end
    end

    def deploy
      unless File.exists? 'wp-config.php'
        error "WordPress not found. Make sure you're at the root level of a WordPress installation."
      end

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

    def wordless_repo
      config[:wordless_repo] || 'git://github.com/welaika/wordless.git'
    end

    def add_git_repo(repo, destination)
      run_command "git clone #{repo} #{destination}"
    end

  end
end

