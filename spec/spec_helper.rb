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
