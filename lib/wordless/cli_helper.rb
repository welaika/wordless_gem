module Wordless
  module CLIHelper

    def info(message)
      log_message message
    end

    def error(message)
      log_message message, :red
      exit
    end

    def success(message)
      log_message message, :green
    end

    def warning(message)
      log_message message, :yellow
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
      run_command "unzip #{file} -d #{destination}"
    end

    def git_installed?
      run_command("git --version")
    end

    private

    def log_message(message, color = nil)
      say message, color
    end

    def void
      RbConfig::CONFIG['host_os'] =~ /msdos|mswin|djgpp|mingw/ ? 'NUL' : '/dev/null'
    end

    def run_command(command)
      system("#{command} >>#{void} 2>&1")
    end

  end
end
