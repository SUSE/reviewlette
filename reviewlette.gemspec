# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reviewlette/version'

Gem::Specification.new do |spec|
  spec.name          = "reviewlette"
  spec.version       = Reviewlette::VERSION
  spec.authors       = ["Joshua Schmidt", "Thomas Hutterer"]
  spec.email         = ["thutterer@suse.de"]
  spec.summary       = %q{Randomly assignes a reviewer to your GitHub pull request and corresponding Trello card.}
  spec.description   = %q{Easy, fair and trackable labor division in your team.}
  spec.homepage      = "https://github.com/SUSE/reviewlette"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'ruby-trello'
  spec.add_runtime_dependency 'octokit'
end
