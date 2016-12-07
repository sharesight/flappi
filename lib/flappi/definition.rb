# frozen_string_literal: true
# rubocop:disable Metrics/LineLength
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
    attr_accessor :defining_class

    # @private
    def requested_version
      @delegate.requested_version
    end

    # @private
    def requested_version=(rv)
      @delegate.requested_version = rv
    end

    # @private
    def version_plan
      @delegate.version_plan
    end

    # @private
    def version_plan=(vp)
      @delegate.version_plan = vp
    end

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
      if @version_rule.nil?
        version_plan.available_version_definitions
      else
        version_plan.expand_version_rule(@version_rule)
      end
    end

    # @private
    def document_as_version(documenting_version_text)
      return documenting_version_text || '0.0.0' unless version_plan

      supported_versions = @version_rule ? version_plan.expand_version_rule(@version_rule) : version_plan.available_version_definitions
      return documenting_version_text || version_plan.minimum_version if supported_versions.blank?

      doc_version_matcher = version_plan.parse_version(documenting_version_text).normalise
      use_versions = supported_versions.select { |v| v == doc_version_matcher } # with wildcards

      raise "#{endpoint_info[:title]}: Multiple versions supported #{use_versions} - not allowed by documenter as yet in #{endpoint_simple_name}" if use_versions.size > 1
      raise "#{endpoint_info[:title]}: Version could not be determined, trying to document unsupported endpoint #{documenting_version_text}" if use_versions.empty?
      use_versions.first
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
    def build(options = {}, &block)
      @delegate.build options, &block
    end

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
    #   @option options [Boolean] :when if false, omit this object
    #   @option options [Hash] :version specify a versioning rule as a hash (see #version for spec for the rule). If present, this object will only we shown if the rule is met.
    #   @option options [String] :dynamic_key Rather than a fixed name, specify a key that is valid at request time.
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
    #   @option options [Boolean] :when if false, omit this object
    #   @option options [Hash] :version specify a versioning rule as a hash (see #version for spec for the rule). If present, this object will only we shown if the rule is met.
    #   @option options [Boolean] :hashed - produce a hash rather than a collection. The hash key is defined with {#hash_key}
    #   @yield A block that will be called to generate the response fields using nested {#field}, {#object} and {#objects} elements. The block will be called for each array value in sequence.
    #   @yieldparam  [Object] current_source the current source object iterated from the enclosing context
    #
    # @overload objects(options)
    #   Define an object (which will be rendered within json as name:hash or inlined into the parent hash).
    #   @option options [String] :name the name of the array field
    #   @option options [Object] :value either an array, in which case each value will become a result entry, or a scalar which will produce a single result.
    #   @option options [Boolean] :compact remove nil entries from the result array
    #   @option options [Boolean] :when if false, omit this object
    #   @option options [Hash] :version specify a versioning rule as a hash (see #version for spec for the rule). If present, this object will only we shown if the rule is met.
    #   @option options [Boolean] :hashed - produce a hash rather than a collection. The hash key is defined with {#hash_key}
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
    #   @option options [String] :doc_name where a field has a dynamic name (computed value) then use this value, enclosed in underscores, as the name of the field.
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
    #   @option options [Boolean] :when if false, omit this object
    #   @option options [Hash] :version specify a versioning rule as a hash (see #version for spec for the rule). If present, this field will only we shown if the rule is met.
    #   @option options [String] :doc_name where a field has a dynamic name (computed value) then use this value, enclosed in underscores, as the name of the field.
    #   @yield A block that will be called to return the field value
    #   @yieldparam  [Object] current_source the current source object
    def field(*args_or_name, &block)
      @delegate.field(*args_or_name, block)
    end

    # Define the hash key to be used in generating a hash from {#objects}
    #
    # @overload hash_key(value, options={})
    #   Define the hash key as having a specified value
    #   @param value (Object) the value for the hash key
    #   @option options [Boolean] :when if false, omit this object
    #
    # @overload hash_key(options={})
    #   Define the hash key with named options
    #   @option options [Object] :value if given, the value to output
    #   @option options [Boolean] :when if false, omit this object
    #
    def hash_key(*args, &block)
      @delegate.hash_key(*args, block)
    end

    # Creates a sideloaded reference to an object created by the block. The object must include an ID field
    #
    # @overload reference(name, options={})
    #   Define a reference sourcing data from the enclosing source object.
    #   If no block is given, the reference object will be extracted from source_object[name], otherwise it will be the block return.
    #   @param name (String) the name of the field
    #   @option options [String] :type creates a polymorphic reference for a named type, requires 'for'
    #   @option options [Object] :for for a polymorphic relation, provide the type that is being requested/generated. (This will usually be from model data or request)
    #   @option options [Boolean] :generate_from_type generate (inline) a name_type field with the type value
    #   @option options [Boolean] :link_id generate a link id name_id in the source location. Defaults to true
    #   @yield A block that will be called to return the referenced object
    #   @yieldparam  [Object] current_source the current source object
    #   @yieldreturn the referenced object
    #
    # @overload reference(name, value, options={})
    #   Define a reference sourcing data from the enclosing source object.
    #   If no block is given, the reference object will be extracted from source_object[name], otherwise it will be the block return.
    #   @param name (String) the name of the field
    #   @param value (Object) the referenced object
    #   @option options [String] :type creates a polymorphic reference for a named type, requires 'for'
    #   @option options [Object] :for for a polymorphic relation, provide the type that is being requested/generated. (This will usually be from model data or request)
    #   @option options [Boolean] :generate_from_type generate (inline) a name_type field with the type value
    #   @option options [Boolean] :link_id generate a link id name_id in the source location. Defaults to true
    #
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
    def response_example(*v)
      set_example('response', v)
    end

    # Define an example request path (no scheme or host) that will be included in documentation.
    # If not specified, the {#path} is used.
    # @param v (String) The request example URL
    def request_example(*v)
      set_example('request', v)
    end

    # @private
    def set_example(example_type, v)
      raise "#{example_type}_example needs at least a text" if v.size.zero?
      options, text = if v.size == 1
                        [{}, v[0]]
                      else
                        v
                      end
      return unless version_wanted(options)

      endpoint_info["#{example_type}_example".to_sym] = text
    end

    # Define an input parameter (inline or query string)
    # This is used to document and validate the parameters.
    #
    # @overload param(name, options={})
    #   Define a named parameter
    #   @param name (String) the name of the parameter
    #   @option options [String] :name the name of the parameter
    #   @option options [Symbol] :type the parameter type, defaults to String
    #   @option options [Object] :default a default value when the parameter is not supplied or is empty
    #   @option options [String] :default_doc text to document the default with instead of a computed default
    #   @option options [String] :doc the parameter description
    #   @option options [Boolean] :optional true for an optional parameter
    #   @yield A block that will be called to validate the parameter
    #   @yieldparam  [Object] param the actual parameter value to validate
    #   @yieldreturn [String] nil if the parameter is valid, else a failure message
    #
    # @overload param(options={})
    #   Define a parameter
    #   @option options [String] :name the name of the parameter
    #   @option options [Symbol] :type the parameter type, defaults to String
    #   @option options [Object] :default a default value when the parameter is not supplied or is empty
    #   @option options [String] :default_doc text to document the default with instead of a computed default
    #   @option options [String] :doc the parameter description
    #   @option options [Boolean] :optional true for an optional parameter
    #   @option options [Integer] :fail code Code to return when fail is true
    #   @yield A block that will be called to validate the parameter
    #   @yieldparam  [Object] param the actual parameter value to validate
    #   @yieldreturn [String] nil if the parameter is valid, else a failure message
    def param(*args_or_name, &block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name

      endpoint_info[:params] <<
        { name: def_args[:name],
          type: name_for_type(def_args[:type]),
          default: def_args[:default],
          default_doc: def_args[:default_doc],
          description: def_args[:doc],
          optional: def_args.key?(:optional) ? def_args[:optional] : true,
          validation_block: block,
          fail_code: def_args[:fail_code] }
    end

    # Define a query to be used to retrieve the source object for the response.
    #
    # @yield A block that will be called to perform the query and return the source object
    # @yieldparam  [Array] controller_params the parameters as passed to the controller
    # @yieldreturn an object to construct the response from
    def query(&block)
      @delegate.query(block)
    end

    # From inside a query, return an error
    # @param status_code (Integer) an HTTP status code to return
    # @param msg (String) a message to return
    def return_error(status_code, msg)
      @delegate.return_error(status_code, msg) if @delegate.respond_to?(:return_error)
    end
  end
end
