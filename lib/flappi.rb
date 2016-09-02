require 'active_support'
require 'active_support/core_ext/module/delegation'

Dir[File.dirname(__FILE__) + '/flappi/**/*.rb'].each {|file| require file }

module Flappi

  class << self
    delegate :build_and_respond, to: Flappi::BuilderFactory

    def configure
      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= Flappi::Config.new
    end
  end

end
