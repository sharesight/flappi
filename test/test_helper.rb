# frozen_string_literal: true

# require 'pry'

if ENV['COVERAGE_ME']
  require 'simplecov'
  SimpleCov.start
end

require 'maxitest/autorun'
require 'shoulda-context'
require 'mocha/minitest'
require 'pry'
require 'flappi'

# Requiring custom test helpers
Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each { |f| require File.expand_path(f) }

Flappi.configure do |conf|
  conf.definition_paths = {
    'v2.0' => 'examples',
    'v2.0-mobile' => 'examples',
    'v2.1.0-mobile' => 'examples',
    'v3.0' => ['examples', 'examples2'],
    'v1.9' => 'examples',
    'default' => 'examples' # when you pass no version, it goes to default
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

module Examples
  class ExampleController
    # this is a stub of a controller, think ActionController
    attr_accessor :params
    attr_accessor :last_render_params
    attr_accessor :last_head_params

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

    def head(params)
      self.last_head_params = params
    end
  end
end
