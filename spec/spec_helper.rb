$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'wordless'
require 'fakeweb'
require 'thor'
require 'pry'

module Wordless
  class WordlessCLI
    def error(message)
      puts message
    end
  end
end

require 'support/capture'
