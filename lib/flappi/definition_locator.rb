
module Flappi
  module DefinitionLocator

    def self.locate_class(endpoint_name)
      paths_array.each do |path|
        candidate_class = (path.camelize + '::' + endpoint_name).constantize
        return candidate_class if candidate_class && candidate_class.included_modules.include?(Flappi::Definition)
      end

      nil
    end

    def self.paths_array
      if Flappi.configuration.definition_paths.is_a? Array
        Flappi.configuration.definition_paths
      else
        [Flappi.configuration.definition_paths]
      end
    end
  end
end
