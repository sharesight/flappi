# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'flappi'
  s.version     = '1.1.0'
  s.summary     = 'Flappi API Builder'
  s.description = 'A flexible DSL-based API builder'
  s.authors     = ['Richard Parratt', 'Sharesight']
  s.email       = 'richard.parratt@sharesight.co.nz'
  s.files       = Dir.glob('{bin,lib}/**/*') + %w[README.md]
  s.homepage    = 'https://github.com/sharesight/flappi'
  s.license = 'MIT'

  s.add_dependency 'activesupport', ">= 7.0", "< 7.2"
  s.add_dependency 'recursive-open-struct'

  s.add_development_dependency 'debug'
  s.add_development_dependency 'maxitest', '~> 6'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake', '>= 12.3'
  s.add_development_dependency 'rubocop', '1.77.0'
  s.add_development_dependency 'rubocop-minitest', '0.10.1'
  s.add_development_dependency 'rubocop-performance', '1.9.0'
  s.add_development_dependency 'shoulda-context'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'warning'
  s.add_development_dependency 'yard'
end
