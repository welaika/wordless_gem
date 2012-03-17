# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordless/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Étienne Després"]
  gem.email         = ["etienne@molotov.ca"]
  gem.description   = %q{Wordless}
  gem.summary       = %q{Manage Wordless themes.}
  gem.homepage      = "http://github.com/etienne/wordless_gem"
  
  gem.add_dependency "thor"
  
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakeweb'
  
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "wordless"
  gem.require_paths = ["lib"]
  gem.version       = Wordless::VERSION
end
