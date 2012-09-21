# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordless/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Étienne Després"]
  gem.email         = ["etienne@molotov.ca"]
  gem.description   = %q{Command line tool to manage Wordless themes.}
  gem.summary       = %q{Manage Wordless themes.}
  gem.homepage      = "http://github.com/etienne/wordless_gem"
  
  gem.add_dependency "thor", "~> 0.16.0"
  gem.add_dependency "wordpress_tools", '~> 0.0.1'
  gem.add_dependency "activesupport", '~> 3.2.0'
  
  gem.add_development_dependency 'rspec', "~> 2.11.0"
  gem.add_development_dependency 'fakeweb'
  
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "wordless"
  gem.require_paths = ["lib"]
  gem.version       = Wordless::VERSION
end
