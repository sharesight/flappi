
# frozen_string_literal: true
module Flappi
  module DefinitionLocator
    def self.locate_class(endpoint_name)
      Flappi.configuration.definition_paths.each do |path|
        candidate_class = begin
                            (path.camelize + '::' + endpoint_name).constantize
                          rescue
                            nil
                          end
        return candidate_class if candidate_class && candidate_class.included_modules.include?(Flappi::Definition)
      end

      nil
    end
  end
end
