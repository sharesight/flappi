Gem::Specification.new do |s|
  s.name        = 'flappi'
  s.version     = '0.2.0'
  s.date        = '2016-09-28'
  s.summary     = "Flappi API Builder"
  s.description = "A flexible DSL-based API builder"
  s.authors     = ["Richard Parratt", "Sharesight"]
  s.email       = 'richard.parratt@sharesight.co.nz'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.homepage    = 'https://github.com/sharesight/flappi'
  s.license       = 'MIT'

  s.add_runtime_dependency 'activesupport', '>4.2.7'
  s.add_runtime_dependency 'recursive-open-struct'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'rake' # slightly unconvinced
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'mocha'
end
