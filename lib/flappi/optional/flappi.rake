namespace :flappi do
  namespace :doc do

    desc 'Extract API documentation from Flappi definitions into ApiDoc'
    task :extract => :environment do
      Flappi::Documenter.document "app/controllers",
                Flappi.configuration.definition_paths.camelize.constantize,  # TODO: multiple paths
                Flappi.configuration.doc_target_path,
                Flappi::ApiDocFormatter
    end
  end
end
