module Flappi
  class Config

    attr_reader :definition_paths
    attr_accessor :version_plan
    attr_accessor :doc_target_path
    attr_accessor :doc_target_paths
    attr_accessor :logger_level
    attr_reader :logger_target

    def definition_paths=(v)
      @definition_paths = (v.is_a? Array) ? v : [v]
    end

    def set_logger_target(&block)
      @logger_target = block
    end

    def set_logger_rails
      set_logger_target {|m, l| Rails.logger.log [Logger::ERROR, Logger::WARN, Logger::INFO, Logger::DEBUG, Logger::DEBUG][l], m }
    end


  end
end
