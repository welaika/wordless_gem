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
end
