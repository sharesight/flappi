# API builder factory - calls API definitions to run controller, generate docs, etc

require 'recursive-open-struct'

module Flappi
  module BuilderFactory

    # extend Shared::Api::Versioning

    # When we run code during a documentation pass, stub everything

    class DocumentingStub
      def method_missing(_meth_id, *_args, &_block)
        # puts "Note: #{_meth_id.id2name} missing, called from stub"
        return DocumentingStub
      end
    end

    class DefDocumenter
      def method_missing(_meth_id, *_args, &_block)
        # puts "Note: #{_meth_id.id2name} missing"
        return DocumentingStub.new
      end
    end

    # Call me from a controller to build the appropriate API response
    # and return it
    def self.build_and_respond(controller)
      endpoint_name = controller.class.name.match(/::(\w+)Controller$/).captures.first
      version_param = controller.params[:version]
      full_version = 'v2.' + version_param if version_param

      definition_klass = DefinitionLocator.locate_class(endpoint_name)
      raise "Endpoint #{endpoint_name} is not defined to API Builder" unless definition_klass

      Rails.logger.debug "  definition_klass = #{definition_klass}"

      controller.singleton_class.send(:include, definition_klass)
      controller.defining_class = definition_klass
      controller.mode = :response
      controller.controller_params = controller.params  # Give the mixin access to params
      controller.controller_query_parameters = controller.request.query_parameters.except(:access_token)
      controller.controller_url = controller.request.url
      controller.version_plan = Flappi.configuration.version_plan

      controller.endpoint    # init endpoint data from mixin

      unless endpoint_name == controller.endpoint_simple_name
        raise "Builderfactory::build_and_respond config issue: controller defines endpoint as #{endpoint_name} and response object as #{controller.endpoint_simple_name}"
      end

      if Flappi.configuration.version_plan
        endpoint_supported_versions = controller.supported_versions
        Rails.logger.debug "  Does endpoint support #{full_version} in #{endpoint_supported_versions}?"
        unless endpoint_supported_versions.include? Flappi.configuration.version_plan.parse_version(full_version)
          msg = "Version #{full_version} not supported by endpoint"
          controller.render json: { error: msg }.to_json, text: msg, status: :not_acceptable
          return false
        end
      end

      # validate parameters
      controller.endpoint_info[:params].each do |defined_param|
        # puts "Check parameter #{defined_param}"
        param_supplied = controller.params.key? defined_param[:name]
        unless param_supplied || defined_param[:optional]
          msg = "Parameter #{defined_param[:name]} is required"
          controller.render json: { error: msg }.to_json, text: msg, status: :not_acceptable
          return false
        end

        next unless param_supplied

        unless validate_param(controller.params[defined_param[:name]], defined_param[:type])
          msg = "Parameter #{defined_param[:name]} must be of type #{defined_param[:type]}"
          controller.render json: { error: msg }.to_json, text: msg, status: :not_acceptable
          return false
        end
      end

      controller.respond_to do |format|
        format.json do
          response_object = controller.respond
          controller.render json: response_object, status: :ok
        end
      end
    end

    # Called to document an API call into a structure that can be templated into e.g. ApiDoc
    def self.document(definition)
      documenter_definition = DefDocumenter.new
      documenter_definition.singleton_class.send(:include, definition)
      documenter_definition.defining_class = definition
      documenter_definition.mode = :doc
      documenter_definition.version_plan = Flappi.configuration.version_plan

      unless documenter_definition.respond_to? :endpoint
        raise 'API definition must include <endpoint> method'
      end
      documenter_definition.endpoint

      # puts "After endpoint call documenter_definition.endpoint_info:"; pp documenter_definition.endpoint_info

      path = documenter_definition.endpoint_info[:path]
      param_docs = documenter_definition.endpoint_info[:params]
      param_docs.select {|p| path.match ":#{p[:name]}(/|$)" }.each {|p| p[:optional] = false }

      hashed_res = {
        endpoint: {
          title: documenter_definition.endpoint_info[:title] || documenter_definition.endpoint_info[:description],
          description: documenter_definition.endpoint_info[:description] || documenter_definition.endpoint_info[:title],
          method_name: documenter_definition.endpoint_info[:method],
          path: path,
          params: param_docs,
          api_name: definition.name.demodulize,
          api_group: documenter_definition.endpoint_info[:group],
          api_version: documenter_definition.document_as_version,
          response_example: documenter_definition.endpoint_info[:response_example]
        },

        # Query parameters, etc
        response: documenter_definition.respond
      }

      # puts "Documenting hashed_res:"; pp hashed_res

      recursive_open_struct_klass = RecursiveOpenStruct
      recursive_open_struct_klass.include DocFormatHelpers
      recursive_open_struct_klass.new(hashed_res, recurse_over_arrays: true)
    end

    def self.validate_param(src, type)
      # puts "validate_param #{src}, type #{type.to_s}"
      case type&.to_s
        when nil
          true
        when 'BOOLEAN'
          src.is_a?(Boolean) || (src.size >= 1 && ['1','0','Y','N','T','F'].include?(src[0].upcase))
        when 'BigDecimal', 'Float'
          src.is_f?
        when 'Integer'
          src.is_i?
        when 'Date'
          return true if src.is_a?(Date)
          Date.parse(src) rescue return false
          true
        else
          true # No idea how to parse
      end
    end
  end
end
