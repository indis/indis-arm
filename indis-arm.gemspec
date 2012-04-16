# -*- encoding: utf-8 -*-
require File.expand_path('../lib/indis-arm/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vladimir Pouzanov"]
  gem.email         = ["farcaller@gmail.com"]
  gem.description   = "ARM and Thumb instruction set code parser for indis"
  gem.summary       = "ARM and Thumb instruction set code parser for indis"
  gem.homepage      = "http://www.indis.org/"
  gem.license       = "GPL-3"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "indis-arm"
  gem.require_paths = ["lib"]
  gem.version       = Indis::ARM::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_runtime_dependency 'indis-core', '~> 0.1.1'
end
