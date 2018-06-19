# frozen_string_literal: true

if ENV['COVERAGE_ME']
  require 'simplecov'
  SimpleCov.start
end

require 'maxitest/autorun'
require 'shoulda'
require 'mocha/mini_test'

require 'flappi'

Flappi.configure do |conf|
  conf.definition_paths = 'examples'
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

module Examples
  class ExampleController
    # this is a stub of a controller, think ActionController
    attr_accessor :params
    attr_accessor :last_render_params

    def initialize
      self.params = {}
    end

    def show
      Flappi.build_and_respond(self)
    end

    def request
      OpenStruct.new(query_parameters: params)
    end

    def respond_to
      yield JsonFormatter.new
    end

    def render(params)
      self.last_render_params = params
    end
  end
end
