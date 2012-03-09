require 'rubygems'
require 'thor'

module Wordless
  class Commands < Thor
    
    desc "new SITE_NAME", "Creates a new Wordless-enabled WordPress installation with a pre-configured Wordless theme"
    def new(name)
      puts "Downloading the latest stable version of WordPress"
      `mkdir #{name} && curl -O http://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz -C #{name}`
    end
    
  end
  
  Commands.start
end
