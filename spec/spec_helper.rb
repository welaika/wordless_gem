require 'wordless/cli'
require 'fakeweb'
require 'thor'

module WordPressTools
  module CLIHelper
    def exit; end
    def info(message); end
    def success(message); end
  end
end

module Wordless
  class WordlessCLI
    def error(message)
      puts message
    end
  end
end

require 'support/capture'

WP_API_RESPONSE = <<-EOF
  upgrade
  http://wordpress.org/download/
  http://wordpress.org/wordpress-3.6.zip
  3.6
  en_US
  5.2.4
  5.0
EOF

RSpec.configure do |config|
  config.before(:all) do
    FileUtils.mkdir('tmp') unless File.directory? 'tmp'
    FakeWeb.allow_net_connect = false

    FakeWeb.register_uri(:get, %r|http://api.wordpress.org/core/version-check/1.5/.*|, :body => WP_API_RESPONSE)
    FakeWeb.register_uri(:get, "http://wordpress.org/wordpress-3.6.zip", :body => File.expand_path('spec/fixtures/wordpress_stub.zip'))
  end
end

