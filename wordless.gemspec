require File.expand_path('../lib/wordless/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Étienne Després", "Ju Liu"]
  gem.email         = ["etienne@molotov.ca", "ju.liu@welaika.com"]
  gem.description   = %q{Command line tool to manage Wordless themes.}
  gem.summary       = %q{Manage Wordless themes.}
  gem.homepage      = "http://github.com/welaika/wordless_gem"
  gem.license       = "MIT"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "wordless"
  gem.require_paths = ["lib"]
  gem.version       = Wordless::VERSION

  gem.add_dependency "thor"
  gem.add_dependency "sprockets"
  gem.add_dependency "compass"
  gem.add_dependency "coffee-script"
  gem.add_dependency "yui-compressor"
  gem.add_dependency "activesupport"
  gem.add_dependency "wordpress_tools", '~> 0.0.2'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakeweb'
end

