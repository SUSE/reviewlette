# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reviewlette'

Gem::Specification.new do |spec|
  spec.name          = "reviewlette"
  spec.version       = VERSION
  spec.authors       = ["jschmid1"]
  spec.email         = ["jschmid@suse.de"]
  spec.summary       = %q{Randomly assignes a reviewer to your Pullrequest and corresponding Trello Card.}
  spec.description   = %q{Easy, fair and trackable labor division in your team.}
  spec.homepage      = "http://rubygems.org/gems/reviewlette"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'ruby-trello', '=1.1.1'
  spec.add_runtime_dependency 'octokit', '>=3.8.0'
  spec.add_runtime_dependency 'net-telnet'
end

