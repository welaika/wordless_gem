# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wordless/version"

Gem::Specification.new do |spec|
  spec.name          = "wordless"
  spec.version       = Wordless::VERSION
  spec.authors       = ["Étienne Després", "Alessandro Fazzi", "Filippo Gangi Dino", "Ju Liu", "Fabrizio Monti"]
  spec.email         = ["etienne@molotov.ca", "alessandro.fazzi@welaika.com", "filippo.gangidino@welaika.com", "ju.liu@welaika.com", "fabrizio.monti@welaika.com"]
  spec.summary       = %q{Manage Wordless themes.}
  spec.description   = %q{Command line tool to manage Wordless themes.}
  spec.homepage      = "http://github.com/welaika/wordless_gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1.2"

  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "activesupport"
  spec.add_dependency "sprockets"
  spec.add_dependency "compass"
  spec.add_dependency "coffee-script"
  spec.add_dependency "yui-compressor"
  spec.add_dependency "wordpress_tools", "~> 1.1.1"

  spec.add_development_dependency "rspec", "~> 3.2.0"
  spec.add_development_dependency "pry-byebug", "~> 3.0"
  spec.add_development_dependency "priscilla", "~> 1.0"
end

