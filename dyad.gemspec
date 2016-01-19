# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dyad/version'

Gem::Specification.new do |spec|
  spec.name          = "dyad"
  spec.version       = Dyad::VERSION
  spec.authors       = ["skliew"]
  spec.email         = ["skliew@gmail.com"]
  spec.summary       = %q{Ruby bindings to dyad}
  spec.description   = %q{This module provides Ruby bindings to dyad, an asynchronous networking library}
  spec.homepage      = "https://github.com/skliew/ruby-dyad"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", "~> 1.9"
  spec.add_dependency "ffi-compiler", "~> 0.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.1"

  spec.extensions << 'ext/Rakefile'
end
