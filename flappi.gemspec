# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'flappi'
  s.version     = '0.5.5'
  s.date        = '2018-05-14'
  s.summary     = 'Flappi API Builder'
  s.description = 'A flexible DSL-based API builder'
  s.authors     = ['Richard Parratt', 'Sharesight']
  s.email       = 'richard.parratt@sharesight.co.nz'
  s.files       = Dir.glob('{bin,lib}/**/*') + %w[README.md]
  s.homepage    = 'https://github.com/sharesight/flappi'
  s.license = 'MIT'

  s.add_runtime_dependency 'activesupport', '>4.2.7'
  s.add_runtime_dependency 'recursive-open-struct'

  s.add_development_dependency 'maxitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake', '>= 12.3'
  s.add_development_dependency 'rubocop', '0.53'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'simplecov'
end
