# frozen_string_literal: true

if ENV['COVERAGE_ME']
  require 'simplecov'
  SimpleCov.start
end

require 'maxitest/autorun'
require 'shoulda'
require 'mocha/minitest'

require 'flappi'

Flappi.configure do |conf|
  conf.definition_paths = {
    'v2.0' => 'examples',
    'v2.0-mobile' => 'examples',
    'v2.1.0-mobile' => 'examples',
    'v1.9' => 'examples',
    'default' => 'examples' # empty, because half the tests don't have versions...?
  }
  conf.version_plan = nil

  if ENV['TEST_LOGGING']
    if defined?(Rails) && defined(Rails.logger)
      conf.set_logger_target { |m, l| Rails.logger m, [Logger::ERROR, Logger::WARN, Logger::INFO, Logger::DEBUG, Logger::DEBUG][l] }
    else
      conf.set_logger_target { |m, _l| puts m }
    end
  end

  if ENV['TEST_LOGGING']
    conf.logger_level = %w[error warn info debug trace].index(ENV['TEST_LOGGING'])
    puts "conf.logger_level=#{conf.logger_level}"
  end

  Flappi::Utils::Logger.d "conf: #{conf.inspect}"
end

class JsonFormatter
  def json
    yield
  end
end
