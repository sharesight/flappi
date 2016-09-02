namespace :flappi do
  namespace :doc do

    desc 'Extract API documentation from Flappi definitions'
    task :extract => :environment do
      Flappi::Documenter.document "app/controllers",
                Flappi.configuration.definition_paths.first.camelize,  # TODO: multiple paths
                "app/controllers/api/v2/docs/m0", # TODO: move
                Flappi::ApiDocFormatter
    end
  end
end
