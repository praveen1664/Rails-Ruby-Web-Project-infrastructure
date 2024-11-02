# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'infrastrap/version'

Gem::Specification.new do |spec|
  spec.name          = "infrastrap"
  spec.version       = Infrastrap::VERSION
  spec.authors       = ["Grant Petersen-Speelman"]
  spec.email         = ["grantspeelman@gmail.com"]

  spec.summary       = %q{generates ansible, mina and terraform code for your ruby web app}
  spec.description   = %q{generates ansible, mina and terraform code for your ruby web app}
  spec.homepage      = "https://github.com/grantspeelman/infrastrap"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency "bundler", "~> 1.0"
  spec.add_dependency 'git', "~> 1.3"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency 'simplecov-console'
end
