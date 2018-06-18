
# frozen_string_literal: true

module Flappi
  module DefinitionLocator
    def self.locate_class(endpoint_name, version)
      issues = []

      version ||= 'default'
      paths = Flappi.configuration.definition_paths[version]
      raise "Unable to find a definition_path for #{version}." unless paths

      # Ensure an array as a definition_path may be a string or array
      paths = paths.is_a?(Array) ? paths : [paths]

      paths.each do |path|
        candidate_class = nil

        begin
          candidate_class_name = (path.camelize + '::' + endpoint_name)
          candidate_class = candidate_class_name.constantize
        rescue StandardError => ex
          issues << "Could not load #{candidate_class_name} because #{ex} was raised"
        end

        next unless candidate_class

        return candidate_class if candidate_class.included_modules.include?(Flappi::Definition)

        issues << "#{candidate_class_name} does not include Flappi::Definition"
      end

      issues = ['No matching classes found'] if issues.empty?
      raise "Endpoint #{endpoint_name} is not defined to Flappi: #{issues.join('; ')}"
    end
  end
end
