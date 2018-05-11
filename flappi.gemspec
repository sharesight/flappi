# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'flappi'
  s.version     = '0.5.2'
  s.date        = '2017-07-04'
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
  s.add_development_dependency 'rake' # slightly unconvinced
  s.add_development_dependency 'rubocop', '0.53'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'simplecov'
end
