require 'thor'
require 'net/http'
require 'colored'

module Wordless
  class CLI < Thor
    
    desc "wp DIR_NAME", "Downloads the latest stable version of WordPress in a new directory DIR_NAME (default is wordpress)"
    method_option :locale, :aliases => "-l", :desc => "WordPress locale (default is en_US)"
    method_option :bare, :aliases => "-b", :desc => "Remove default themes and plugins"
    def wp(dir_name = 'wordpress')
      download_url, version, locale = Net::HTTP.get('api.wordpress.org', "/core/version-check/1.5/?locale=#{options[:locale]}").split[2,3]
      downloaded_file = Tempfile.new('wordpress')
      begin
        puts "Downloading WordPress #{version} (#{locale})...".green
        `curl #{download_url} > #{downloaded_file.path} && unzip #{downloaded_file.path} -d #{dir_name}`
        subdirectory = Dir["#{dir_name}/*/"].first # This is probably 'wordpress', but don't assume
        FileUtils.mv Dir["#{subdirectory}*"], dir_name # Remove unnecessary directory level
        FileUtils.rmdir subdirectory
      ensure
         downloaded_file.close
         downloaded_file.unlink
      end
      
      puts %Q{Installed WordPress in directory "#{dir_name}"}.green
      
      if options[:bare]
        puts "Removing default themes and plugins...".green
        dirs = %w(themes plugins).map {|d| "#{dir_name}/wp-content/#{d}"}
        FileUtils.rm_rf dirs
        FileUtils.mkdir dirs
        dirs.each do |dir|
          FileUtils.cp "#{dir_name}/wp-content/index.php", dir
        end
      end
      
      puts "Done.".green
      
    end
    
  end
end
