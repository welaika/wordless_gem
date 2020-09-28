lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wordless/version"

Gem::Specification.new do |spec|
  spec.name          = "wordless"
  spec.version       = Wordless::VERSION
  spec.authors       = ["Étienne Després", "Alessandro Fazzi",
                        "Filippo Gangi Dino", "Ju Liu", "Fabrizio Monti"]
  spec.email         = ["etienne@molotov.ca",
                        "alessandro.fazzi@welaika.com",
                        "filippo.gangidino@welaika.com",
                        "ju.liu@welaika.com",
                        "fabrizio.monti@welaika.com"]
  spec.summary       = 'Manage Wordless themes.'
  spec.description   = 'The quickest CLI tool to setup a new WordPress locally. Wordless ready.'
  spec.homepage      = "http://github.com/welaika/wordless_gem"
  spec.license       = "MIT"

  spec.files         =  `git ls-files -z`
                        .split("\x0")
                        .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.1"

  spec.add_dependency "activesupport"
  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "wordpress_tools", "~> 1.4.1"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "debase"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
  spec.add_development_dependency "rake", "~> 13.0.1"
  spec.add_development_dependency "rspec", "~> 3.9.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "ruby-debug-ide"
  spec.add_development_dependency "solargraph"
end
