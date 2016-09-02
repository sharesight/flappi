require 'active_support'
require 'active_support/core_ext/module/delegation'

Dir[File.dirname(__FILE__) + '/flappi/**/*.rb'].each do |file|
  require file unless file.realpath.include? '/optional/'
end

require 'flappi/railtie' if defined?(Rails)

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
