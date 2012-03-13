require 'thor'
require 'net/http'
require 'colored'
require 'rbconfig'

module Wordless
  class CLI < Thor
    
    desc "wp DIR_NAME", "download the latest stable version of WordPress in a new directory DIR_NAME (default is wordpress)"
    method_option :locale, :aliases => "-l", :desc => "WordPress locale (default is en_US)"
    method_option :bare, :aliases => "-b", :desc => "Remove default themes and plugins"
    def wp(dir_name = 'wordpress')
      download_url, version, locale = Net::HTTP.get('api.wordpress.org', "/core/version-check/1.5/?locale=#{options[:locale]}").split[2,3]
      downloaded_file = Tempfile.new('wordpress')
      begin
        puts "Downloading WordPress #{version} (#{locale})..."
        `curl #{download_url} > #{downloaded_file.path} && unzip #{downloaded_file.path} -d #{dir_name}`
        subdirectory = Dir["#{dir_name}/*/"].first # This is probably 'wordpress', but don't assume
        FileUtils.mv Dir["#{subdirectory}*"], dir_name # Remove unnecessary directory level
        FileUtils.rmdir subdirectory
      ensure
         downloaded_file.close
         downloaded_file.unlink
      end
      
      puts %Q{Installed WordPress in directory "#{dir_name}".}.green
      
      if options[:bare]
        dirs = %w(themes plugins).map {|d| "#{dir_name}/wp-content/#{d}"}
        FileUtils.rm_rf dirs
        FileUtils.mkdir dirs
        dirs.each do |dir|
          FileUtils.cp "#{dir_name}/wp-content/index.php", dir
        end
        puts "Removed default themes and plugins.".green
      end
      
      # http://stackoverflow.com/questions/4597490/platform-independent-way-of-detecting-if-git-is-installed
      void = RbConfig::CONFIG['host_os'] =~ /msdos|mswin|djgpp|mingw/ ? 'NUL' : '/dev/null'
      if git_installed?
        if system 'git init'
          puts "Initialized git repository.".green
        else
          puts "Couldn't initialize git repository.".red
        end
      else
        puts "Didn't initialize git repository because git isn't installed.".yellow
      end
    end
    
    desc "new [NAME]", "download WordPress in directory [NAME], install the Wordless plugin and create a Wordless theme"
    method_option :locale, :aliases => "-l", :desc => "WordPress locale (default is en_US)"
    def new(name)
      # upcoming
    end
    
    desc "install", "install the Wordless plugin into an existing WordPress installation as a git submodule"
    def install
      unless git_installed?
        puts "Git is not available. Please install git.".red
        return
      end

      unless File.directory? 'wp-content/plugins'
        puts "Directory 'wp-content/plugins' not found. Make sure you're at the root level of a WordPress installation.".red
        return
      end

      if system "git submodule add git://github.com/welaika/wordless.git wp-content/plugins/wordless && git submodule init && git submodule update"
        puts "Installed Wordless plugin.".green
      end
    end
    
    private
    
    def git_installed?
      void = RbConfig::CONFIG['host_os'] =~ /msdos|mswin|djgpp|mingw/ ? 'NUL' : '/dev/null'
      system "git --version >>#{void} 2>&1"
    end
  end
end
