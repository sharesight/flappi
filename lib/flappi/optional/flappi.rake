# frozen_string_literal: true

namespace :flappi do
  namespace :doc do
    desc 'Extract API documentation from Flappi definitions into ApiDoc. Use VERBOSE=v* to increase log level. ENDPOINT=module to document one endpoint.'
    task extract: :environment do
      raise 'Need to define at least once path in Flappi.configuration.definition_paths' unless Flappi.configuration.definition_paths

      raise 'Need to define a doc target to generate docs' unless Flappi.configuration.doc_target_path || Flappi.configuration.doc_target_paths

      target_paths = Flappi.configuration.doc_target_paths || Flappi.configuration.doc_target_path
      target_paths = { '*' => target_paths } unless target_paths.is_a?(Hash)

      Flappi.configuration.definition_paths.each do |path|
        target_paths.each do |document_version, to_path|
          Flappi::Documenter.document 'app/controllers',
                                      path.camelize.constantize,
                                      to_path,
                                      document_version,
                                      Flappi::ApiDocFormatter
        end
      end
    end
  end
end
