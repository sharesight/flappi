# frozen_string_literal: true

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

    # Use on {#field} and {#param} types when a boolean type is wanted, null values will be null
    BOOLEAN = :boolean_type

    # Use on {#field} and {#param} types when a boolean type is wanted and falsey values
    # will be false, truthy true
    BOOLEAN_STRICT = :boolean_strict

    SOURCE_PRESENT = :source_present

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
      @endpoint_info ||= { params: [], request_examples: [], response_examples: [], api_errors: [] }
    end

    # @private
    def endpoint_simple_name
      defining_class.name.match(/::(\w+)$/).captures.first
    end

    # @private
    def supported_versions
      if @version_rule
        version_plan.expand_version_rule(@version_rule)
      else
        version_plan.available_version_definitions
      end
    end

    # @private
    def document_as_version(documenting_version_text)
      return documenting_version_text || '0.0.0' unless version_plan

      supported_versions = if @version_rule
                             version_plan.expand_version_rule(@version_rule)
                           else
                             version_plan.available_version_definitions
                           end
      return documenting_version_text || version_plan.minimum_version if supported_versions.blank?

      doc_version_matcher = version_plan.parse_version(documenting_version_text).normalise
      use_versions = supported_versions.select { |v| v == doc_version_matcher } # with wildcards

      if use_versions.size > 1
        raise "#{endpoint_info[:title]}: Multiple versions supported #{use_versions}"\
              " - not allowed by documenter as yet in #{endpoint_simple_name}"
      end
      if use_versions.empty?
        raise "#{endpoint_info[:title]}: Version could not be determined, trying to"\
              " document unsupported endpoint #{documenting_version_text}"
      end

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

    # Define how to build the API response. Use this typically with a block that defines
    # how each field of the response is to be generated.
    #
    # @option options [Class] :type
    #   Specifies a (ruby) type, an instance of which will be retrieved by calling the
    #   classes (ActiveRecord-style) 'where' method with the controller's parameters and
    #   will become the base object the response is generated from.
    # @option options [Symbol] :as
    #   Specifies the class method to call in place on the `type`
    # @option options [Hash] :options
    #   Optionally specify an array of options which will be passed to the 'where' method
    #   of class 'type'
    #
    # @example fetch a user record
    #   build type: User do
    #        ...
    #   end
    #
    # @yield A block that will be called to generate the response using {#field},
    #   {#object} and {#objects} elements.
    # @yieldparam [Object] base_object
    #   The base object we generate the response from. If you don't use explicit value
    #   expressions in {#field} etc, you don't need this.
    def build(options = {}, &block)
      @delegate.build options, &block
    end

    # Define an object (which will be rendered within json as name:hash).
    # Use this with a block that defines the fields of the object hash.
    # For a named object, if no source data exists (is nil) then no object will be rendered.
    # (Set value: true if the block can render with no input)
    #
    # @overload object(name)
    #   Defines a named object using the enclosing source object.
    #   @param name (String)
    #     The name of the object
    #   @yield A block that will be called to generate the response fields using nested
    #     {#field}, {#object} and {#objects} elements.
    #   @yieldparam  [Object] current_source the current source object from the enclosing
    #     context
    #
    # @overload object(name, value)
    #   Define an object using a specified value.
    #   @param name (String)
    #     The name of the object
    #   @param value (Object)
    #     The object to extract fields from
    #   @yield A block that will be called to generate the response fields using nested
    #     {#field}, {#object} and {#objects} elements.
    #   @yieldparam  [Object] current_source the current source object (passed as value)
    #
    # @overload object(options)
    #   Define an object (which will be rendered within json as name:hash or inlined into
    #   the parent hash).
    #   @option options [String] :name
    #     The name of the object
    #   @option options [Object] :value
    #     The object to extract fields from
    #   @option options [Object] :source
    #     The name of a hash or method in the current source to get the data from, instead
    #     of :name
    #   @option options [Boolean] :inline_always
    #     Rather than creating this object's hash, inline its fields into the parent
    #   @option options [Boolean] :when
    #     If false, omit this object, if SOURCE_PRESENT, omit unless a data source is present
    #   @option options [Hash] :version
    #     Specify a versioning rule as a hash (see #version for spec for the rule). If
    #     present, this object will only we shown if the rule is met.
    #   @option options [String] :dynamic_key
    #     Rather than a fixed name, specify a key that is valid at request time.
    #   @yield A block that will be called to generate the response fields using nested
    #     {#field}, {#object} and {#objects} elements.
    #   @yieldparam [Object] current_source
    #     The current source object (passed as value)
    def object(*args_or_name, &block)
      @delegate.object(*args_or_name, block)
    end

    # Define multiple objects which will be rendered into json as an array of object hashes.
    # Use this with a block that defines the fields of each object hash. The array is generated
    # by iterating over the source object (if an Array) or with one field (if scalar).
    #
    # @overload objects(name, options={})
    #   Defines a named array object using the enclosing source object. Will generate name:
    #   array in json.
    #   @param name (String)
    #     The name of the array field
    #   @option options [Boolean] :compact
    #     Remove nil entries from the result array
    #   @yield A block that will be called to generate the response fields using nested
    #     {#field}, {#object} and {#objects} elements. The block will be called for each
    #     array value in sequence.
    #   @yieldparam [Object] current_source
    #     The current source object iterated from the enclosing context
    #
    # @overload objects(name, value, options={})
    #   Defines a named array object using a specified (array or scalar) value.
    #   Will generate name: array in json.
    #   @param name (String)
    #     The name of the array field
    #   @param value (Object)
    #     Either an array, in which case each value will become a result entry, or a scalar
    #     which will produce a single result.
    #   @option options [Boolean] :compact
    #     Remove nil entries from the result array
    #   @option options [Boolean] :when
    #     If false, omit this object, if SOURCE_PRESENT, omit unless a data source is present
    #   @option options [Hash] :version
    #     Specify a versioning rule as a hash (see #version for spec for the rule). If
    #     present, this object will only we shown if the rule is met.
    #   @option options [Boolean] :hashed
    #     Produce a hash rather than a collection. The hash key is defined with {#hash_key}
    #   @yield A block that will be called to generate the response fields using nested
    #     {#field}, {#object} and {#objects} elements. The block will be called for each
    #     array value in sequence.
    #   @yieldparam [Object] current_source
    #     The current source object iterated from the enclosing context
    #
    # @overload objects(options)
    #   Define an object (which will be rendered within json as name:hash or inlined into
    #   the parent hash).
    #   @option options [String] :name
    #     The name of the array field
    #   @option options [Object] :value
    #     Either an array, in which case each value will become a result entry, or a
    #     scalar which will produce a single result.
    #   @option options [Object] :source
    #     The name of a hash or method in the current source to get the data array from,
    #     instead of :name
    #   @option options [Boolean] :compact
    #     Remove nil entries from the result array
    #   @option options [Boolean] :when
    #     If false, omit this object, if SOURCE_PRESENT, omit unless a data source is present
    #   @option options [Hash] :version
    #     Specify a versioning rule as a hash (see #version for spec for the rule). If
    #     present, this object will only we shown if the rule is met.
    #   @option options [Boolean] :hashed
    #     Produce a hash rather than a collection. The hash key is defined with {#hash_key}
    #   @yield A block that will be called to generate the response fields using nested
    #     {#field}, {#object} and {#objects} elements.
    #   @yieldparam [Object] current_source
    #     The current source object iterated from the enclosing context
    def objects(*args_or_name, &block)
      @delegate.objects(*args_or_name, block)
    end

    # Define a single (scalar) field in the result. This will produce a name:value
    # pair in the json response.
    #
    # @overload field(name)
    #   Define a field sourcing data from the enclosing source object. If no block
    #   is given, the field value will be extracted from source_object[name], otherwise
    #   it will be the block return.
    #   @param name (String)
    #     The name of the field
    #   @option options [Boolean] :compact
    #     Remove nil entries from the result array
    #   @option options [String] :doc_name
    #     Where a field has a dynamic name (computed value) then use this value, enclosed
    #     in underscores, as the name of the field.
    #   @option options [String] :type
    #     A type to coerce the value to: :Integer, :BigDecimal, :Float
    #
    #   @yield A block that will be called to return the field value
    #   @yieldparam [Object] current_source
    #     The current source object
    #
    # @overload field(name, value)
    #   Define a field with an explicitly specified value.
    #   @param name (String) the name of the field
    #   @param value (Object) the value to output
    #
    # @overload field(options={})
    #   Define a field with named options
    #   @option options [String] :name
    #     The name of the field
    #   @option options [Object] :value
    #     If given, the value to output
    #   @option options [Object] :source
    #     The name of a hash or method in the current source to get the data from,
    #     instead of :name
    #   @option options [Boolean] :when
    #     If false, omit this object, if SOURCE_PRESENT, omit unless a data source
    #     is present
    #   @option options [Hash] :version
    #     Specify a versioning rule as a hash (see #version for spec for the rule).
    #     If present, this field will only we shown if the rule is met.
    #   @option options [String] :doc_name
    #     Where a field has a dynamic name (computed value) then use this value,
    #     enclosed in underscores, as the name of the field.
    #   @option options [String] :type
    #     A type to coerce the value to: :Integer, :BigDecimal, :Float
    #
    #   @yield A block that will be called to return the field value
    #   @yieldparam [Object] current_source the current source object
    def field(*args_or_name, &block)
      @delegate.field(*args_or_name, block)
    end

    # Define the hash key to be used in generating a hash from {#objects}
    #
    # @overload hash_key(value, options={})
    #   Define the hash key as having a specified value
    #   @param value (Object)
    #     The value for the hash key
    #   @option options [Boolean] :when
    #     If false, omit this object, if SOURCE_PRESENT, omit unless a data source is
    #     present
    #
    # @overload hash_key(options={})
    #   Define the hash key with named options
    #   @option options [Object] :value
    #     If given, the value to output
    #   @option options [Boolean] :when
    #     If false, omit this object, if SOURCE_PRESENT, omit unless a data source is
    #     present
    #
    def hash_key(*args, &block)
      @delegate.hash_key(*args, block)
    end

    # Creates a sideloaded reference to an object created by the block. The object
    # must include an ID field
    #
    # @overload reference(name, options={})
    #   Define a reference sourcing data from the enclosing source object. If no block
    #   is given, the reference object will be extracted from source_object[name],
    #   otherwise it will be the block return.
    #   @param name (String) the name of the field
    #   @option options [String] :type
    #     Creates a polymorphic reference for a named type, requires 'for'
    #   @option options [Object] :for
    #     For a polymorphic relation, provide the type that is being requested/generated.
    #     (This will usually be from model data or request)
    #   @option options [Boolean] :generate_from_type
    #     Generate (inline) a name_type field with the type value
    #   @option options [Boolean] :link_id
    #     Generate a link id name_id in the source location. Defaults to true
    #   @yield A block that will be called to return the referenced object
    #   @yieldparam [Object] current_source
    #     The current source object
    #   @yieldreturn the referenced object
    #
    # @overload reference(name, value, options={})
    #   Define a reference sourcing data from the enclosing source object.
    #   If no block is given, the reference object will be extracted from
    #   source_object[name], otherwise it will be the block return.
    #   @param name (String) the name of the field
    #   @param value (Object) the referenced object
    #   @option options [String] :type
    #     Creates a polymorphic reference for a named type, requires 'for'
    #   @option options [Object] :for
    #     For a polymorphic relation, provide the type that is being
    #     requested/generated. (This will usually be from model data or request)
    #   @option options [Boolean] :generate_from_type
    #     Generate (inline) a name_type field with the type value
    #   @option options [Boolean] :link_id
    #     Generate a link id name_id in the source location. Defaults to true
    #
    def reference(*args_or_name, &block)
      @delegate.reference(*args_or_name, block)
    end

    # Specify a link to be provided in the response
    # Links defined at the top level will be output at the end of the response
    # Links defined at object level will be output at the end of the object
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
    def http_method(v)
      endpoint_info[:http_method] = v
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
    # This assumes that a version plan (which defines semantic versioning and
    # version flavours) is configured into Flappi.
    #
    # @option version_rule [String] :equals
    #   A version which must be matched for the endpoint to be supported. The
    #   version can be wildcarded with '*'.
    # @option version_rule [String] :matches
    #   Synonym for equals
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

    # Define an API error
    def api_error(status_code, field_name, field_description)
      endpoint_info[:api_errors] << {
        status_code: status_code,
        response_field_name: field_name,
        response_field_description: field_description
      }
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

      endpoint_info[:"#{example_type}_examples"] << {
        label: options[:label],
        content: text
      }
    end

    # Define an input parameter (inline or query string)
    # This is used to document and validate the parameters.
    #
    # Chain processor &block to this to define a parameter processor
    # and/or validator &block for define a parameter validator
    #
    # @overload param(name, options={})
    #   Define a named parameter
    #   @param name (String) the name of the parameter
    #   @option options [String] :name
    #     The name of the parameter
    #   @option options [Symbol] :type
    #     The parameter type, defaults to String, allowed types are `Boolean`,
    #     `BigDecimal`, `Float`, `Integer`, `Date`, `String`, `Array`. For `Array`,
    #     the input params can be defined using comma separated or [] syntax
    #   @option options [Object] :default
    #     A default value when the parameter is not supplied or is empty
    #   @option options [String] :default_doc
    #     Text to document the default with instead of a computed default
    #   @option options [String] :doc
    #     The parameter description
    #   @option options [Boolean] :hidden
    #     If true don't document
    #   @option options [Boolean] :optional
    #     True for an optional parameter
    #   @yield A block that will be called to validate the parameter
    #   @yieldparam  [Object] param the actual parameter value to validate
    #   @yieldreturn [String] nil if the parameter is valid, else a failure message
    #   @return [ParamProcessor] chain this with processor or validator
    #
    # @overload param(options={})
    #   Define a parameter
    #   @option options [String] :name
    #     The name of the parameter, which can be in a path
    #   @option options [Symbol] :type
    #     The parameter type, defaults to String, allowed types are `Boolean`,
    #     `BigDecimal`, `Float`, `Integer`, `Date`, `String`, `Array`. For `Array`,
    #     the input params can be defined using comma separated or [] syntax
    #   @option options [Object] :default
    #     A default value when the parameter is not supplied or is empty
    #   @option options [String] :default_doc
    #     Text to document the default with instead of a computed default
    #   @option options [String] :doc
    #     The parameter description
    #   @option options [Boolean] :hidden
    #     If true don't document
    #   @option options [Boolean] :optional
    #     True for an optional parameter
    #   @option options [Integer] :fail
    #     Code to return when fail is true
    #   @yield A block that will be called to validate the parameter
    #   @yieldparam  [Object] param the actual parameter value to validate
    #   @yieldreturn [String] nil if the parameter is valid, else a failure message
    #   @return [ParamProcessor] chain this with processor or validator
    def param(*args_or_name, &block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name

      return unless version_wanted(def_args)

      param_def = { name: def_args[:name],
                    type: name_for_type(def_args[:type]),
                    default_doc: def_args[:default_doc],
                    description: def_args[:doc],
                    hidden: def_args[:hidden],
                    optional: def_args.key?(:optional) ? def_args[:optional] : true,
                    validation_block: block,
                    fail_code: def_args[:fail_code] }

      # options that take nil
      param_def[:default] = def_args[:default] if def_args.key?(:default)

      endpoint_info[:params] << param_def

      ParamProcessor.new(param_def)
    end

    # Enable parameter check for strict parameters in Rails
    def check_params(mode = false)
      endpoint_info[:check_params] = mode
    end

    # Enable/disable strict mode, unknown parameters will cause an error
    # Default is to disable this
    def strict(mode = false)
      endpoint_info[:strict_mode] = mode
    end

    # Define a query to be used to retrieve the source object for the response.
    #
    # @yield A block that will be called to perform the query and return the source object
    # @yieldparam  [Array] controller_params the parameters as passed to the controller
    # @yieldreturn an object to construct the response from
    def query(&block)
      @delegate.query(block)
    end

    # From inside a query, return 204 NO CONTENT
    def return_no_content
      @delegate.return_no_content if @delegate.respond_to?(:return_no_content)
    end

    # From inside a query, return an error
    # @param status_code (Integer) an HTTP status code to return
    # @param error_info (Object) a message String or an error hash to return
    def return_error(status_code, error_info)
      @delegate.return_error(status_code, error_info) if @delegate.respond_to?(:return_error)
    end

    # The major version for documentation and example purposes
    def major_version
      @delegate.requested_version&.major
    end
  end
end
