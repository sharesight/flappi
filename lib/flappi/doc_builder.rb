# Build API documentation from a definition
require_relative 'common'

module Flappi
  class DocBuilder
    include Common

    def build(_options, &_block)
      @object_path = []
      @document = []
      yield Flappi::BuilderFactory::DocumentingStub.new    # More will happen
      @document
    end

    def object(*args_or_name, block)
      object_one_or_many(*args_or_name, false, block)
    end

    def objects(*args_or_name, block)
      object_one_or_many(*args_or_name, true, block)
    end

    def field(*args_or_name, _block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name

      @document << { name: @object_path.clone + [def_args[:name]],
                     type: name_for_type(def_args[:type]),
                     description: def_args[:doc] }
    end

    def reference(*args_or_name, block)
      # TODO: document references
    end


    def query(block)
    end

    private

    def object_one_or_many(*args_or_name, is_many, block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name

      @object_path << def_args[:name]
#       # puts "object_one_or_many @object_path=#{@object_path} def_args[:name]=#{def_args[:name]}"
      @document << { name: @object_path.clone,
                     type: name_for_type(def_args[:type]) + (is_many ? '[]' : ''),
                     description: def_args[:doc] }

      block.call Flappi::BuilderFactory::DocumentingStub.new

      @object_path.pop
    end


  end
end
