namespace :flappi do
  namespace :doc do

    desc 'Extract API documentation from Flappi definitions into ApiDoc'
    task :extract => :environment do
      Flappi.configuration.definition_paths.each do |path|
        Flappi::Documenter.document "app/controllers",
                  path.camelize.constantize,
                  Flappi.configuration.doc_target_path,
                  Flappi::ApiDocFormatter
        end
    end
  end
end
