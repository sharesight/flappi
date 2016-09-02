namespace :flappi do
  namespace :doc do

    desc 'Extract API documentation from Flappi definitions into ApiDoc'
    task :extract => :environment do

      unless Flappi.configuration.definition_paths
        raise "Need to define at least once path in Flappi.configuration.definition_paths"
      end

      unless Flappi.configuration.doc_target_path
        raise "Need to define a doc target to generate docs"
      end

      Flappi.configuration.definition_paths.each do |path|
        Flappi::Documenter.document "app/controllers",
                  path.camelize.constantize,
                  Flappi.configuration.doc_target_path,
                  Flappi::ApiDocFormatter
        end
    end
  end
end
