if ENV['COVERAGE_ME']
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require 'shoulda'

require 'flappi'

Flappi.configure do |conf|
  conf.definition_paths = 'examples'
end
