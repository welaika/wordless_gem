require 'open-uri'

module Wordless
  module CLIHelper
    def error(message)
      say message, :red
    end

    def success(message)
      say message, :green
    end

    def warning(message)
      say message, :yellow
    end

    def download(url, destination)
      begin
        f = open(destination, "wb")
        f.write(open(url).read) ? true : false
      rescue
        false
      ensure
        f.close
      end
    end

    def unzip(file, destination)
      run "unzip #{file} -d #{destination}", :verbose => false, :capture => true
    end

    def git_installed?
      # http://stackoverflow.com/questions/4597490/platform-independent-way-of-detecting-if-git-is-installed
      void = RbConfig::CONFIG['host_os'] =~ /msdos|mswin|djgpp|mingw/ ? 'NUL' : '/dev/null'
      system "git --version >>#{void} 2>&1"
    end

    def add_git_repo(repo, destination)
      run "git clone #{repo} #{destination}", :verbose => false, :capture => true
    end
  end
end
