# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daily_report_generator/version'

Gem::Specification.new do |spec|
  spec.name          = "radirepo"
  spec.version       = DailyReportGenerator::VERSION
  spec.authors       = ["KOTERA Yuki"]
  spec.email         = ["kotera@radicode.co.jp"]

  spec.summary       = %q{A summary generator of GitHub activity for retrospective.}
  spec.description   = %q{A summary generator of GitHub activity for retrospective.}
  spec.homepage      = "https://github.com/radicodeinc/daily_report_generator"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'octokit', '~> 4.1.1'
  spec.add_dependency 'pit', '~> 0.0.7'
  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end

