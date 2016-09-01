# Common helpers for each builder, include into DocBuilder, ResponseBuilder, etc.

module Flappi
  module Common

    NAMED_TYPES = {
        :boolean_type => 'Boolean'
    }

    attr_accessor :source_definition

    # Extract the common arguments on each definition
    # A hash is a simple hash of options
    # The first arg is taken as the name
    # the second arg (if not a hash) is taken as the value
    def extract_definition_args(args_or_name)
      # puts "extract_definition_args(#{args_or_name})"
      case args_or_name
        when Hash
          args_or_name.with_indifferent_access
        when Array
          case args_or_name.size
            when 1
              if args_or_name[0].is_a?(Hash)
                args_or_name[0].with_indifferent_access
              else
                { name: args_or_name[0] }.with_indifferent_access
              end

            when 2
              if args_or_name[1].is_a?(Hash)
                { name: args_or_name[0] }.merge(args_or_name[1]).with_indifferent_access
              else
                { name: args_or_name[0], value: args_or_name[1] }.with_indifferent_access
              end

          end
        else
          { name: args_or_name }.with_indifferent_access
      end
    end

    def require_arg(args, arg_name)
      raise "Expecting #{arg_name} to be defined (in...)" unless args.key?(arg_name)
    end

    def name_for_type(type_arg)
      return type_arg.name.demodulize if type_arg.is_a?(Class)
      return 'String' if type_arg.nil?
      return NAMED_TYPES[type_arg] if NAMED_TYPES.key?(type_arg)
      return type_arg if type_arg.is_a?(String)

      '**Unknown**' # and maybe produce a message
    end

  end
end
