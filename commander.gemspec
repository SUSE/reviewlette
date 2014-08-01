# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commander/version'

Gem::Specification.new do |spec|
  spec.name          = "happy-commander"
  spec.version       = Commander::VERSION
  spec.authors       = ["jschmid1"]
  spec.email         = ["jschmid@suse.de"]
  spec.summary       = %q{Automatically sets a Commanding officer of the Week.}
  spec.description   = %q{Easy, fair and trackable labor division in your team.}
  spec.homepage      = "http://rubygems.org/gems/happy-commander"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'ruby-trello', '=1.1.1'
  spec.add_runtime_dependency 'json', '=1.7.7'
  spec.add_runtime_dependency 'colorize', '=0.7.3'
end
