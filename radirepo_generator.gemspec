# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'radirepo_generator/version'

Gem::Specification.new do |spec|
  spec.name          = "radirepo_generator"
  spec.version       = RadirepoGenerator::VERSION
  spec.authors       = ["KOTERA Yuki"]
  spec.email         = ["kotera@radicode.co.jp"]

  spec.summary       = %q{A summary generator of GitHub activity for retrospective in radicode inc.}
  spec.description   = %q{A summary generator of GitHub activity for retrospective in radicode inc.}
  spec.homepage      = "https://github.com/radicodeinc/radirepo_generator"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'octokit', '~> 4.1.1'
  spec.add_dependency 'pit', '~> 0.0.7'
  spec.add_dependency 'thor'
  spec.add_dependency 'launchy'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  # spec.add_development_dependency "minitest"
end

