module Flappi
  module Config

    def self.definition_paths
      Settings.api_builder.definition_paths
    end

    def self.version_plan
      Settings.api_builder.version_plan.constantize
    end
  end
end
