# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/module/delegation'

# Require dependent files first and make sure order of required files is deterministic
DEPENDENT_FILES = ['common.rb', 'utils/param_types.rb'].freeze

root_path = "#{File.dirname(__FILE__)}/flappi/"
dependent_file_paths = DEPENDENT_FILES.map { |f| root_path + f }

found_file_paths = Dir["#{root_path}**/*.rb"]

(dependent_file_paths | found_file_paths).each do |file|
  require file unless file.include? '/optional/'
end

require 'flappi/optional/railtie' if defined?(Rails)

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
