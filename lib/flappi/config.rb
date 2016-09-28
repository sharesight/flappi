module Flappi
  class Config

    attr_reader :definition_paths
    attr_accessor :version_plan
    attr_accessor :doc_target_path
    attr_accessor :doc_target_paths

    def definition_paths=(v)
        @definition_paths = (v.is_a? Array) ? v : [v]
    end

  end
end
