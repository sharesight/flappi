module Flappi
  # DSL for API construction.
  #
  # This DSL defines methods which can be used to construct API responses, docs, etc.
  # Include it in each API endpoint definition as shown below:
  #
  # @example
  #   include Flappi::Definition
  #
  #   def endpoint
  #    # Define your endpoint here using {#method}, {#title}, {#description}, {#version}, {#group}, {#path}
  #    #   #{response_example}, #{param}
  #    #   #{query}
  #   end
  #
  #   def response
  #    # Define your response here using #{build}
  #   end
  #
  module Definition

    # @private
    include Common

    # Use on {#field} and {#param} types when a boolean type is wanted
    BOOLEAN = :boolean_type

    # @private
    attr_reader :delegate
    # @private
    attr_accessor :version_plan
    # @private
    attr_accessor :defining_class

    # @private
    def endpoint_info
      @endpoint_info ||= { params: [] }
    end

    # @private
    def endpoint_simple_name
      defining_class.name.match(/::(\w+)$/).captures.first
    end

    # @private
    def supported_versions
      @version_rule.nil? ?
          version_plan.available_version_definitions :
          version_plan.expand_version_rule(@version_rule)
    end

    # @private
    def document_as_version
      return '0.0.0' unless version_plan

      return version_plan.minimum_version if @version_rule.nil?
      supported_versions = version_plan.expand_version_rule(@version_rule)
      return version_plan.minimum_version if supported_versions.blank?

      raise "Multiple versions supported #{supported_versions} - not allowed by documenter as yet in #{endpoint_simple_name}" if supported_versions.size > 1
      supported_versions.first
    end

    # @private
    def mode=(mode)
      @delegate = "Flappi::#{mode.to_s.camelize}Builder".constantize.new
      @delegate.source_definition = self
    end

    # @private
    def controller_params=(p)
      @delegate.controller_params = p if @delegate.respond_to? :controller_params=
    end

    # @private
    def controller_query_parameters=(p)
      @delegate.controller_query_parameters = p if @delegate.respond_to? :controller_query_parameters=
    end

    # @private
    def controller_url=(p)
      @delegate.controller_url = p if @delegate.respond_to? :controller_url=
    end

    # Define how to build the API response.
    # Use this typically with a block that defines how each field of the response is to be generated.
    #
    # @option options [Class] :type Specifies a (ruby) type, an instance of which will be retrieved by calling the classes (ActiveRecord-style) 'where' method with the controller's parameters and will become the base object the response is generated from.
    # @example fetch a user record
    #   build type: User do
    #        ...
    #   end
    #
    # @yield A block that will be called to generate the response using {#field}, {#object} and {#objects} elements.
    # @yieldparam  [Object] base_object the base object we generate the response from. If you don't use explicit value expressions in {#field} etc, you don't need this.
    def build(options={}, &block)
      @delegate.build options, &block
    end

    # TODO: we may need this with adaptive versioning
#    def include_when(test)
#      yield if test
#    end

    # Define an object (which will be rendered within json as name:hash).
    # Use this with a block that defines the fields of the object hash.
    #
    # @overload object(name)
    #   Defines a named object using the enclosing source object.
    #   @param name (String) the name of the object
    #   @yield A block that will be called to generate the response fields using nested {#field}, {#object} and {#objects} elements.
    #   @yieldparam  [Object] current_source the current source object from the enclosing context
    #
    # @overload object(name, value)
    #   Define an object using a specified value.
    #   @param name (String) the name of the object
    #   @param value (Object) the object to extract fields from
    #   @yield A block that will be called to generate the response fields using nested {#field}, {#object} and {#objects} elements.
    #   @yieldparam  [Object] current_source the current source object (passed as value)
    #
    # @overload object(options)
    #   Define an object (which will be rendered within json as name:hash or inlined into the parent hash).
    #   @option options [String] :name the name of the object
    #   @option options [Object] :value the object to extract fields from
    #   @option options [Boolean] :inline_always rather than creating this object's hash, inline its fields into the parent
    #   @yield A block that will be called to generate the response fields using nested {#field}, {#object} and {#objects} elements.
    #   @yieldparam  [Object] current_source the current source object (passed as value)
    def object(*args_or_name, &block)
      @delegate.object(*args_or_name, block)
    end

    # Define multiple objects which will be rendered into json as an array of object hashes.
    # Use this with a block that defines the fields of each object hash. The array is generated
    # by iterating over the source object (if an Array) or with one field (if scalar).
    #
    # @overload objects(name, options={})
    #   Defines a named array object using the enclosing source object.
    #   Will generate name: array in json.
    #   @param name (String) the name of the array field
    #   @option options [Boolean] :compact remove nil entries from the result array
    #   @yield A block that will be called to generate the response fields using nested {#field}, {#object} and {#objects} elements. The block will be called for each array value in sequence.
    #   @yieldparam  [Object] current_source the current source object iterated from the enclosing context
    #
    # @overload objects(name, value, options={})
    #   Defines a named array object using a specified (array or scalar) value.
    #   Will generate name: array in json.
    #   @param name (String) the name of the array field
    #   @param value (Object) either an array, in which case each value will become a result entry, or a scalar which will produce a single result.
    #   @option options [Boolean] :compact remove nil entries from the result array
    #   @yield A block that will be called to generate the response fields using nested {#field}, {#object} and {#objects} elements. The block will be called for each array value in sequence.
    #   @yieldparam  [Object] current_source the current source object iterated from the enclosing context
    #
    # @overload objects(options)
    #   Define an object (which will be rendered within json as name:hash or inlined into the parent hash).
    #   @option options [String] :name the name of the array field
    #   @option options [Object] :value either an array, in which case each value will become a result entry, or a scalar which will produce a single result.
    #   @option options [Boolean] :compact remove nil entries from the result array
    #   @yield A block that will be called to generate the response fields using nested {#field}, {#object} and {#objects} elements.
    #   @yieldparam  [Object] current_source the current source object iterated from the enclosing context
    def objects(*args_or_name, &block)
      @delegate.objects(*args_or_name, block)
    end

    # Define a single (scalar) field in the result. This will produce a name:value pair in the json response.
    #
    # @overload field(name)
    #   Define a field sourcing data from the enclosing source object.
    #   If no block is given, the field value will be extracted from source_object[name], otherwise it will be the block return.
    #   @param name (String) the name of the field
    #   @option options [Boolean] :compact remove nil entries from the result array
    #   @yield A block that will be called to return the field value
    #   @yieldparam  [Object] current_source the current source object
    #
    # @overload field(name, value)
    #   Define a field with an explicitly specified value.
    #   @param name (String) the name of the field
    #   @param value (Object) the value to output
    #
    # @overload field(options={})
    #   Define a field with named options
    #   @option options [String] :name the name of the field
    #   @option options [Object] :value if given, the value to output
    #   @yield A block that will be called to return the field value
    #   @yieldparam  [Object] current_source the current source object
    def field(*args_or_name, &block)
      @delegate.field(*args_or_name, block)
    end

    # call this with either:
    #  name and block - create a reference to the object created by the block, which must include an ID field
    #  hash of options including :name, :value
    #   type: creates a polymorphic relation and specify the generate time type
    #
    # TODO: Polymorphism needs to be able to absolutely specify fields for doco
    def reference(*args_or_name, &block)
      @delegate.reference(*args_or_name, block)
    end

    # Specify a link to be provided in the response
    #
    # @overload link(:self)
    #   @param key (String) (:self, to generate the link that produces this result)
    # @overload link(key, path)
    #   @param key (String) :self to generate the link that produces this result or an endpoint name
    #   @param path (String) the (parameterised) path to generate the link from
    # @overload link(options={})
    #   @param [Hash] options parameters passed to create the link
    #   @option options [String] :key :self to generate the link that produces this result or an endpoint name
    #   @option options [String] :path (String) the (parameterised) path to generate the link from
    def link(*link_params)
      @delegate.link(*link_params) if @delegate.respond_to? :link
    end

    # Endpoint methods

    # Define the HTTP method - note however that Rails and the controller is responsible for routing
    # @param v (String) GET, POST, PUT, DELETE
    def method(v)
      endpoint_info[:method] = v
    end

    # Define the title
    # @param v (String) The title to be shown in documentation.
    def title(v)
      endpoint_info[:title] = v
    end

    # Define the description
    # @param v (String) The longer description to be shown in documentation.
    def description(v)
      endpoint_info[:description] = v
    end

    # Define the version this endpoint works with.
    #
    # This assumes that a version plan (which defines semantic versioning and version flavours) is configured into Flappi.
    #
    # @option version_rule [String] :equals A version which must be matched for the endpoint to be supported. The version can be wildcarded with '*'.
    def version(version_rule)
      raise "No version plan is defined - cannot use 'version'" unless version_plan
      @version_rule = version_rule
    end

    # Define the API group this endpoint is in - used to break documentation into sections
    # @param v (String) The group name.
    def group(v)
      endpoint_info[:group] = v
    end

    # Define the path to this endpoint under the API root.
    # This is for documentation only.
    # @param v (String) The path, with parameters.
    def path(v)
      endpoint_info[:path] = v
    end

    # Define an example response that will be included in documentation.
    # @param v (String) The response example.
    def response_example(v)
      endpoint_info[:response_example] = v
    end

    # Define an input parameter (inline or query string)
    # This is used to document and validate the parameters.
    #
    # @overload param(name, options={})
    #   Define a named parameter
    #   @param name (String) the name of the parameter
    #   @option options [String] :name the name of the parameter
    #   @option options [Symbol] :type the parameter type, defaults to String
    #   @option options [String] :doc the parameter description
    #   @option options [Boolean] :optional true for an optional parameter
    #
    # @overload param(options={})
    #   Define a parameter
    #   @option options [String] :name the name of the parameter
    #   @option options [Symbol] :type the parameter type, defaults to String
    #   @option options [String] :doc the parameter description
    #   @option options [Boolean] :optional true for an optional parameter
    def param(*args_or_name)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name

      endpoint_info[:params] <<
          { name: def_args[:name],
            type: name_for_type(def_args[:type]),
            description: def_args[:doc],
            optional: def_args.key?(:optional) ? def_args[:optional] : true
          }
    end

    # Define a query to be used to retrieve the source object for the response.
    #
    # @yield A block that will be called to perform the query and return the source object
    # @yieldparam  [Array] controller_params the parameters as passed to the controller
    # @yieldreturn an object to construct the response from
    def query(&block)
      @delegate.query(block)
    end

  end
end
