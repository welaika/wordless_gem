require 'wordless/cli'
require 'fakeweb'
require 'thor'

# Set shell to basic
# $0 = "thor"
# $thor_runner = true
# ARGV.clear
# Thor::Base.shell = Thor::Shell::Basic

RSpec.configure do |config|
  FakeWeb.allow_net_connect = false
  
  $stdout = StringIO.new
  
  # Stub Wordless::CLI#wordless_repo to avoid hitting the network when testing Wordless installation
  # FIXME - Need to be able to selectively stub this
  # config.before(:each, :stub_wordless_install => true) do
  #   module Wordless
  #     class CLI
  #       no_tasks do
  #         def wordless_repo
  #           File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'wordless_stub'))
  #         end
  #       end
  #     end
  #   end
  # end
  
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end
end
