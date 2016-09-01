
module Flappi
  class Documenter

    # TODO: we will support generating different ApiDoc for different versions at some stage
    # Call to document all definitions under top_module
    def self.document(top_path, top_module, into_path, with_formatter)
      load_all_modules top_path + '/' + top_module.to_s.underscore
      defs_to_document = builder_definitions(top_module)

      # puts "Documenting definitions: #{defs_to_document}"
      defs_to_document.map do |defi|
        into_file = (into_path + defi.to_s[top_module.to_s.length..-1].underscore).sub(/\/([^\/]+)$/, '/show_\1.rb')
        with_formatter.format(BuilderFactory.document(defi), into_file)
      end
    end

    def self.builder_definitions(from)
      all_the_modules(from).select {|m| m.ancestors.include? Flappi::Definition }
    end

    def self.load_all_modules(from)
      Dir.glob("#{from}/**/*.rb") {|file| load file }
    end

    def self.all_the_modules(from)
      [from] + from.constants.map {|const| from.const_get(const) }
                   .select {|const| const.is_a? Module }
                   .flat_map {|const| all_the_modules(const) }
    end

  end
end
