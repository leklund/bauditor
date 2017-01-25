# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bauditor/version'

Gem::Specification.new do |spec|
  spec.name          = 'bauditor'
  spec.version       = Bauditor::VERSION
  spec.authors       = ['Lukas Eklund']
  spec.email         = ['lukas@eklund.io']

  spec.summary       = %q{Run bundler-audit on multiple repositories}
  spec.homepage      = 'https://github.com/leklund/bauditor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'
  spec.add_dependency 'bundler-audit'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
