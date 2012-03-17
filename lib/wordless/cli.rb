require 'thor'
# require 'thor/shell/basic'
require 'net/http'
require 'rbconfig'
require 'tempfile'
require 'wordless/cli_helper'

module Wordless
  class CLI < Thor
    include Wordless::CLIHelper
    
    desc "wp DIR_NAME", "download the latest stable version of WordPress in a new directory DIR_NAME (default is wordpress)"
    method_option :locale, :aliases => "-l", :desc => "WordPress locale (default is en_US)"
    method_option :bare, :aliases => "-b", :desc => "Remove default themes and plugins"
    def wp(dir_name = 'wordpress')
      download_url, version, locale = Net::HTTP.get('api.wordpress.org', "/core/version-check/1.5/?locale=#{options[:locale]}").split[2,3]
      downloaded_file = Tempfile.new('wordpress')
      begin
        puts "Downloading WordPress #{version} (#{locale})..."

        unless download(download_url, downloaded_file.path)
          error "Couldn't download WordPress."
          return
        end
        
        unless unzip(downloaded_file.path, dir_name)
          error "Couldn't unzip WordPress."
          return
        end
        
        subdirectory = Dir["#{dir_name}/*/"].first # This is probably 'wordpress', but don't assume
        FileUtils.mv Dir["#{subdirectory}*"], dir_name # Remove unnecessary directory level
        Dir.delete subdirectory
      ensure
         downloaded_file.close
         downloaded_file.unlink
      end
      
      success %Q{Installed WordPress in directory "#{dir_name}".}
      
      if options[:bare]
        dirs = %w(themes plugins).map {|d| "#{dir_name}/wp-content/#{d}"}
        FileUtils.rm_rf dirs
        FileUtils.mkdir dirs
        dirs.each do |dir|
          FileUtils.cp "#{dir_name}/wp-content/index.php", dir
        end
        success "Removed default themes and plugins."
      end
      
      if git_installed?
        if system "cd #{dir_name} && git init"
          success "Initialized git repository."
        else
          error "Couldn't initialize git repository."
        end
      else
        warning "Didn't initialize git repository because git isn't installed."
      end
    end
    
    desc "new NAME", "download WordPress in directory NAME, install the Wordless plugin and create a Wordless theme"
    method_option :locale, :aliases => "-l", :desc => "WordPress locale (default is en_US)"
    def new(name)
      # upcoming
    end
    
    desc "install", "install the Wordless plugin into an existing WordPress installation as a git submodule"
    def install
      unless git_installed?
        error "Git is not available. Please install git."
        return
      end

      unless File.directory? 'wp-content/plugins'
        error "Directory 'wp-content/plugins' not found. Make sure you're at the root level of a WordPress installation."
        return
      end

      if system "git submodule add git://github.com/welaika/wordless.git wp-content/plugins/wordless && git submodule init && git submodule update"
        success "Installed Wordless plugin."
      else
        error "There was an error installing the Wordless plugin."
      end
    end
  end
end
