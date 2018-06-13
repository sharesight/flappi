# frozen_string_literal: true

module Flappi
  class Config

    attr_accessor :definition_paths
    attr_accessor :version_plan
    attr_accessor :doc_target_path
    attr_accessor :doc_target_paths
    attr_accessor :logger_level
    attr_reader :logger_target

    # rubocop:disable Naming/AccessorMethodName
    def set_logger_target(&block)
      @logger_target = block
    end
    # rubocop:enable Naming/AccessorMethodName

    def set_logger_rails
      set_logger_target {|m, l| Rails.logger.send %i[error warn info debug debug][l], m }
    end

  end
end
