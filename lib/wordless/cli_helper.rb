module Wordless
  module CLIHelper
    extend ActiveSupport::Concern

    included do
      %i[say run].each do |sym|
        define_method sym do |*args|
          thor.send(sym, *args)
        end
        private sym # rubocop:disable Style/AccessModifierDeclarations
      end
    end

    private

    def thor
      raise NotImplementedError, "Including class must provide a thor instance object"
    end

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

    def ensure_wp_cli_installed!
      error("Cannot continue: WP-CLI is not installed.") unless wp_cli_installed?
    end

    def run_command(command)
      system("#{command} >>#{void} 2>&1")
    end

    def wp_cli_installed?
      run_command("which wp")
    end

    def log_message(message, color = nil)
      say message, color
    end

    def void
      /msdos|mswin|djgpp|mingw/.match? RbConfig::CONFIG['host_os'] ? 'NUL' : '/dev/null'
    end
  end
end
