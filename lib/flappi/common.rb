# Common helpers for each builder, include into DocBuilder, ResponseBuilder, etc.

# @private
module Flappi
  module Common

    # @private
    NAMED_TYPES = {
        :boolean_type => 'Boolean'
    }

    # @private
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
            when 0
              {}
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

            when 3
              { name: args_or_name[0], value: args_or_name[1] }.merge(args_or_name[2]).with_indifferent_access

            else
              raise "Unexpected >3 positional arguments at #{args_or_name}"
          end
        else
          { name: args_or_name }.with_indifferent_access
      end
    end

    # Extract the common arguments on a definition
    # that doesn't take a name
    # A hash is a simple hash of options
    # the second arg is taken as the value
    # hashed options follow
    def extract_definition_args_nameless(args)
      # puts "extract_definition_args_nameless(#{args})"
      case args
        when Hash
          args.with_indifferent_access
        when Array
          case args.size
            when 0
              {}
            when 1
              if args[0].is_a?(Hash)
                args[0].with_indifferent_access
              else
                { value: args[0] }.with_indifferent_access
              end

            when 2
              { value: args[0] }.merge(args[1]).with_indifferent_access

            else
              raise "Unexpected >2 positional arguments at #{args}"
          end
        else
          { value: args }.with_indifferent_access
      end
    end

    def require_arg(args, arg_name)
      raise "Expecting #{arg_name} to be defined (in #{args&.keys&.join(', ')})" unless args&.key?(arg_name)
    end

    def name_for_type(type_arg)
      return type_arg.name.demodulize if type_arg.is_a?(Class)
      return 'String' if type_arg.nil?
      return NAMED_TYPES[type_arg] if NAMED_TYPES.key?(type_arg)
      return type_arg if type_arg.is_a?(String)

      '**Unknown**' # and maybe produce a message
    end

    def version_wanted(def_args)
      return true unless def_args.key?(:version)
      version_rule = def_args[:version]

      supported_versions = version_plan.expand_version_rule(*version_rule)
      # puts "version check #{supported_versions} includes #{requested_version}"
      supported_versions.include?(requested_version)
    end

  end
end
