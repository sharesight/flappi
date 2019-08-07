# frozen_string_literal: true

module Flappi
  class Documenter
    # Call to document all definitions under top_module
    def self.document(top_path, top_module, into_path, for_version, with_formatter)
      FileUtils.mkdir_p into_path

      load_all_modules top_path + '/' + top_module.to_s.underscore, top_module
      defs_to_document = builder_definitions(top_module)

      Flappi::Utils::Logger.i "Documenting definitions: #{defs_to_document} endpoint=#{ENV['endpoint']} version=#{for_version}"
      defs_to_document.map do |defi|
        next if ENV['endpoint'] && ENV['endpoint'] != defi.to_s

        Flappi::Utils::Logger.d "Documenting #{defi}"

        into_file = (into_path + defi.to_s[top_module.to_s.length..-1].underscore).sub(/\/([^\/]+)$/, '/show_\1.rb')
        with_formatter.format(BuilderFactory.document(defi, for_version), into_file)
      end
    end

    def self.builder_definitions(from)
      all_the_modules(from).select do |m|
        m.ancestors.include?(Flappi::Definition) && m.method_defined?(:endpoint) && m.method_defined?(:respond)
      end
    end

    def self.load_all_modules(from, top_module)
      Flappi::Utils::Logger.d "Loading from #{from} : #{top_module}"
      Dir.glob("#{from}/**/*.rb") do |file|
        expected_klass = begin
                           Module.const_get(top_module.to_s + '::' + File.basename(file, '.*').camelize)
                         rescue StandardError
                           nil
                         end
        # The autoloader may load our module anyway here

        unless all_the_modules(top_module).include?(expected_klass)
          # puts "loading #{file}"

          load file
        end
      end
    end

    def self.all_the_modules(from)
      [from] + from.constants.map { |const| from.const_get(const) }
                   .select { |const| const.is_a? Module }
                   .flat_map { |const| all_the_modules(const) }
    end
  end
end
