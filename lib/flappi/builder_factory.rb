# frozen_string_literal: true

# API builder factory - calls API definitions to run controller, generate docs, etc

require 'recursive-open-struct'
require 'active_support/json'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

module Flappi
  module BuilderFactory
    extend Flappi::Utils::ParamTypes

    # When we run code during a documentation pass, stub everything

    class DocumentingStub
      def to_ary
        [DocumentingStub.new]
      end

      def method_missing(meth_name, *args)
        return DocumentingStub.new unless %i[to_ary method_missing respond_to_missing?].include? meth_name

        super
      end

      def respond_to_missing?(method_name, _include_private = false)
        !%i[to_ary method_missing respond_to_missing?].include?(method_name) || super
      end

      def self.method_missing(meth_name, *_args, &_block)
        return DocumentingStub.new unless %i[to_ary method_missing respond_to_missing?].include? meth_name

        super
      end

      def self.respond_to_missing?(method_name, _include_private = false)
        !%i[method_missing respond_to_missing?].include?(method_name) || super
      end
    end

    class DefDocumenter
      def method_missing(meth_name, *args)
        return DocumentingStub.new unless %i[method_missing respond_to_missing?].include? meth_name

        super
      end

      def respond_to_missing?(method_name, _include_private = false)
        !%i[method_missing respond_to_missing?].include?(method_name) || super
      end
    end

    # Call me from a controller to build the appropriate API response
    # and return it
    def self.build_and_respond(controller, method = nil)
      definition_klass, endpoint_name, full_version = locate_definition(controller, method)

      normalised_version = nil
      if Flappi.configuration.version_plan
        raise "BuilderFactory::build_and_respond has a version plan #{Flappi.configuration.version_plan} so needs a version from the router" unless full_version

        normalised_version = Flappi.configuration.version_plan.parse_version(full_version).normalise
      end

      load_controller(controller, definition_klass, endpoint_name, normalised_version)

      if Flappi.configuration.version_plan
        endpoint_supported_versions = controller.supported_versions
        Flappi::Utils::Logger.d "  Does endpoint support #{full_version} in #{endpoint_supported_versions}?" if defined?(Rails)
        unless endpoint_supported_versions.include? normalised_version
          validate_error = "Version #{full_version} not supported by endpoint"
          Flappi::Utils::Logger.w validate_error
          controller.render json: { error: validate_error }.to_json, plain: validate_error, status: :not_acceptable
          return false
        end
      end

      defined_params = controller.endpoint_info[:params]
      apply_default_parameters controller.params, defined_params
      process_parameters controller.params, defined_params

      validate_error, fail_code = validate_parameters(controller.params, defined_params, controller.endpoint_info[:strict_mode])
      if validate_error
        Flappi::Utils::Logger.w validate_error
        controller.render json: { error: validate_error }.to_json, plain: validate_error, status: fail_code || :not_acceptable
        return false
      end

      controller.respond_to do |format|
        format.json do
          return render_response_json(controller)
        end
      end
    end

    # Called to document an API call into a structure that can be templated into e.g. ApiDoc
    def self.document(definition, for_version)
      documenter_definition, normalised_version = init_documenter_definition(definition, for_version)

      if Flappi.configuration.version_plan
        raise 'BuilderFactory::build_and_respond has a version plan so needs a version from the router' unless for_version

        endpoint_supported_versions = documenter_definition.supported_versions
        return nil unless endpoint_supported_versions.include? normalised_version
      end

      path = documenter_definition.endpoint_info[:path]
      param_docs = make_param_docs(documenter_definition, path)

      hashed_res = make_documentation_result(definition, documenter_definition, for_version, param_docs, path)
      # puts "Documenting hashed_res:"; pp hashed_res

      recursive_open_struct_klass = RecursiveOpenStruct
      recursive_open_struct_klass.include DocFormatHelpers
      recursive_open_struct_klass.new(hashed_res, recurse_over_arrays: true)
    end

    def self.init_documenter_definition(definition, for_version)
      documenter_definition = DefDocumenter.new
      documenter_definition.singleton_class.send(:include, definition)
      documenter_definition.defining_class = definition
      documenter_definition.mode = :doc

      normalised_version = Flappi.configuration.version_plan&.parse_version(for_version)&.normalise
      documenter_definition.requested_version = normalised_version

      documenter_definition.version_plan = Flappi.configuration.version_plan

      raise 'API definition must include <endpoint> method' unless documenter_definition.respond_to? :endpoint

      documenter_definition.endpoint

      Flappi::Utils::Logger.d "After endpoint call documenter_definition.endpoint_info: #{documenter_definition.endpoint_info.inspect}"
      [documenter_definition, normalised_version]
    end

    def self.make_param_docs(documenter_definition, path)
      param_docs = documenter_definition.endpoint_info[:params]
      param_docs.select { |p| path.match ":#{p[:name]}(/|$)" }.each { |p| p[:optional] = false }
      param_docs.reject! { |p| p[:hidden] }
      param_docs
    end

    def self.make_documentation_result(definition, documenter_definition, for_version, param_docs, path)
      request_examples = documenter_definition.endpoint_info[:request_examples]
      request_examples = [{ content: "\"#{path}\"" }] if !request_examples || request_examples.empty?
      {
        endpoint: {
          title: documenter_definition.endpoint_info[:title] || documenter_definition.endpoint_info[:description],
          description: documenter_definition.endpoint_info[:description] || documenter_definition.endpoint_info[:title],
          method_name: documenter_definition.endpoint_info[:http_method],
          path: path,
          params: param_docs,
          api_name: definition.name.demodulize,
          api_group: documenter_definition.endpoint_info[:group],
          api_version: documenter_definition.document_as_version(for_version),
          response_examples: documenter_definition.endpoint_info[:response_examples],
          request_examples: request_examples,
          api_errors: documenter_definition.endpoint_info[:api_errors]
        },

        # Query parameters, etc
        response: documenter_definition.respond
      }
    end

    # validate actual parameters against definitions, return an error message if fails
    def self.validate_parameters(actual_params, defined_params, strict_mode = false)
      defined_params.each do |defined_param|
        Flappi::Utils::Logger.d "Check parameter #{defined_param} in #{actual_params}"

        # Find the nested param
        param_path = defined_param[:name].to_s.split('/')
        actual_param = Flappi::Utils::HashKeyUtils.dig_indifferent(actual_params, *param_path)
        return ["Parameter #{defined_param[:name]} is required", defined_param[:fail_code]] unless actual_param || defined_param[:optional]

        next unless actual_param

        return ["Parameter #{defined_param[:name]} must be of type #{defined_param[:type]}", defined_param[:fail_code]] unless validate_param(actual_param, defined_param[:type])

        # Bury the casted param
        casted_param = cast_param(actual_param, defined_param[:type], defined_param[:name])
        Flappi::Utils::HashKeyUtils.bury_indifferent(actual_params, casted_param, *param_path)

        if defined_param[:validation_block]
          error_text = defined_param[:validation_block].call(actual_param)
          return ["Parameter #{defined_param[:name]} failed validation: #{error_text}", defined_param[:fail_code]] if error_text
        end
      end

      if strict_mode
        rails_params = ['format', 'version', 'controller', 'action', 'access_token']
        param_hash = if actual_params.respond_to?(:to_unsafe_h)
          actual_params.to_unsafe_h
        else
          actual_params.to_h
        end

        wrong_params = pathify_hash(nil, param_hash) - \
          (defined_params.map { |p| p[:name].to_s } + rails_params)

        return ["Parameter(s) #{wrong_params.join(', ')} not recognised in strict mode", :not_acceptable] if wrong_params.present?
      end

      nil
    end

    def self.pathify_hash(prefix, h)
      h.flat_map do |k, v|
        prefixed_k = [prefix, k].compact.map(&:to_s).join('/')
        if v.is_a?(Hash)
          pathify_hash(prefixed_k, v)
        else
          prefixed_k
        end
      end
    end

    # process parameters through any processors defined on the param
    def self.process_parameters(actual_params, defined_params)
      defined_params.each do |defined_param|
        actual_params[defined_param[:name]] = defined_param[:processor_block].call(actual_params[defined_param[:name]]) if defined_param[:processor_block]
      end
    end

    # Merge in default values where one is defined and we don't have an actual parameter
    #
    # If a parameter is blank and no default is defined, the parameter stays blank
    # If we have no parameter and no default is defined, no parameter is passed on
    # If a parameter is either missing or blank and a default is defined, it is used
    def self.apply_default_parameters(actual_params, defined_params)
      actual_params.merge!(defined_params.select do |defined_param|
                             param = Flappi::Utils::HashKeyUtils.dig_indifferent(actual_params, defined_param[:name])
                             (param.nil? || param == '') && defined_param.key?(:default)
                           end.map do |defined_param|
                             [defined_param[:name], defined_param[:default]]
                           end.to_h)

      Flappi::Utils::Logger.d "After apply_default_parameters actual_params=#{actual_params}"
    end

    def self.locate_definition(controller, method)
      endpoint_name = controller.class.name.match(/(?:::)?(\w+)Controller$/).captures.first
      endpoint_name << method.to_s.camelize if method

      full_version = controller.params[:version]

      definition_klass = DefinitionLocator.locate_class(endpoint_name, full_version)
      [definition_klass, endpoint_name, full_version]
    end

    def self.load_controller(controller, definition_klass, endpoint_name, normalised_version)
      Flappi::Utils::Logger.d "  definition_klass = #{definition_klass}" if defined?(Rails)

      controller.singleton_class.send(:include, definition_klass)
      controller.defining_class = definition_klass
      controller.mode = :response
      controller.controller_params = controller.params # Give the mixin access to params
      controller.controller_query_parameters = controller.request.query_parameters.except(:access_token)
      controller.controller_url = controller.request.url
      Flappi::Utils::Logger.i "controller.request.url=#{controller.request.url}"
      controller.version_plan = Flappi.configuration.version_plan
      controller.requested_version = normalised_version

      controller.endpoint # init endpoint data from mixin

      unless endpoint_name == controller.endpoint_simple_name
        raise "BuilderFactory::build_and_respond config issue: controller defines endpoint as #{endpoint_name} and response object as #{controller.endpoint_simple_name}"
      end
    end

    def self.render_response_json(controller)
      response_object = controller.respond

      # return 204 no content when no content is given rather than parsing it as either `null` or `{}` with a 200 response.
      # this is only when you omit the build, eg just `def respond; end`
      return controller.head :no_content unless response_object
      return controller.head :no_content if response_object.respond_to?(:status_code) && response_object.status_code == 204

      if response_object.respond_to?(:status_code)
        error_info = response_object.status_error_info
        response_hash = error_info.is_a?(String) ? { error: error_info } : { errors: error_info }
        controller.render json: response_hash.to_json, plain: error_info, status: response_object.status_code
      else
        controller.render json: response_object, status: :ok
      end

      response_object
    end
  end
end
