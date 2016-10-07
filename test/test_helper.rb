if ENV['COVERAGE_ME']
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require 'shoulda'
