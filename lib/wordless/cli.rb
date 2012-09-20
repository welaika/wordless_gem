require 'thor'
require 'net/http'
require 'rbconfig'
require 'tempfile'
require 'wordpress_tools/cli'
require 'wordless/cli_helper'

module Wordless
  class CLI < Thor
    include Thor::Actions
    include Wordless::CLIHelper

    @@lib_dir = File.expand_path(File.dirname(__FILE__))

    no_tasks do
      def wordless_repo
        'git://github.com/welaika/wordless.git'
      end
    end

    desc "new [NAME]", "download WordPress in specified directory, install the Wordless plugin and create a Wordless theme"
    method_option :locale, :aliases => "-l", :desc => "WordPress locale (default is en_US)"
    def new(name)
      WordPressTools::CLI.new.invoke('new', [name], :bare => true, :locale => options['locale'])
      Dir.chdir(name)
      Wordless::CLI.new.invoke(:install)
      invoke('theme', [name])
    end

    desc "install", "install the Wordless plugin into an existing WordPress installation"
    def install
      unless git_installed?
        error "Git is not available. Please install git."
        return
      end

      unless File.directory? 'wp-content/plugins'
        error "Directory 'wp-content/plugins' not found. Make sure you're at the root level of a WordPress installation."
        return
      end

      if add_git_repo wordless_repo, 'wp-content/plugins/wordless'
        success "Installed Wordless plugin."
      else
        error "There was an error installing the Wordless plugin."
      end
    end

    desc "theme NAME", "create a new Wordless theme NAME"
    def theme(name)
      unless File.directory? 'wp-content/themes'
        error "Directory 'wp-content/themes' not found. Make sure you're at the root level of a WordPress installation."
        return
      end

      # Run PHP helper script
      if system "php #{File.join(@@lib_dir, 'theme_builder.php')} #{name}"
        success "Created a new Wordless theme in 'wp-content/themes/#{name}'."
      else
        error "Couldn't create Wordless theme."
        return
      end
    end

    desc "compile", "compile static assets"
    def compile
      if system "php #{File.join(@@lib_dir, 'compile_assets.php')}"
        success "Compiled static assets."
      else
        error "Couldn't compile static assets."
      end
    end
  end
end
