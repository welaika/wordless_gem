require 'open-uri'

module Wordless
  class CLIHelper
    def self.download(url, destination)
      f = open(destination, "wb")
      f.write(open(url).read)
      f.close
    end

    def self.unzip(file, destination)
      system "unzip #{file} -d #{destination}"
    end

    def self.git_installed?
      # http://stackoverflow.com/questions/4597490/platform-independent-way-of-detecting-if-git-is-installed
      void = RbConfig::CONFIG['host_os'] =~ /msdos|mswin|djgpp|mingw/ ? 'NUL' : '/dev/null'
      system "git --version >>#{void} 2>&1"
    end
  end
end