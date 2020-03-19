# frozen_string_literal: true

# Build an API response from a definition
require 'uri'
require 'cgi'
require 'active_support/core_ext/hash/conversions'
require 'active_support/core_ext/hash/indifferent_access'

module Flappi
  class ResponseBuilder
    include Common

    # The params array from a (Rails) controller
    attr_accessor :controller_params
    # The request.query_parameters (as in GET params from the controller, minus access_token. Raw rather than cooked)
    attr_accessor :controller_query_parameters
    attr_accessor :controller_url
    attr_reader :query_block
    attr_accessor :requested_version
    attr_accessor :version_plan

    def initialize
      @query_block = nil

      # The link stack collects links defined at object/objects level
      # Each entry is an array of links
      # Init here as `link` can be outside `build`
      @link_stack = [[]]

      @current_source = nil
    end

    # Call this with a block that builds the API response
    def build(options, &_block)
      # puts "response_builder::build, class= #{self.class} self="; pp self;
      base_object = nil
      @status_code = nil

      permitted_params = if source_definition.endpoint_info[:check_params]
        controller_params.respond_to?(:permit) ? controller_params.permit(*params_to_permit) : controller_params
      else
        controller_params
                         end

      if @query_block
        # We have a query block defined, call it to get the model object
        base_object = @query_block.call(permitted_params)

        # puts "ResponseBuilder::build - query_block got "; pp base_object
      elsif options.key?(:type)
        # construct a model of type with the parameters
        # which we should have by virtue of being mixed into the controller
        as_method = options[:as]&.to_sym || :where
        base_object = if options.key?(:options)
                        options[:type].send(as_method, permitted_params, options[:options])
                      else
                        options[:type].send(as_method, permitted_params)
                      end
      else
        # We have no query, so all methods use e.g constant values
        # so we define it as an empty hash
        base_object = {}
      end

      # If return_error called, return a struct
      return OpenStruct.new(status_code: @status_code, status_error_info: @status_error_info) if @status_code

      @response_tree = new_h

      # The put stack defines where in the response tree we put to
      @put_stack = [@response_tree]

      # The hash stack keeps track of hash keys defined for each hashed object, so we can
      # pop back to outputting into the correct hash
      @hash_stack = []

      # the source stack tracks chnages to the source in objects/object
      @source_stack = []

      @references = new_h
      @current_source = base_object

      if base_object
        yield @current_source
      else
        yield
      end

      @current_source = nil

      @references.each do |k, r|
        @response_tree[k] = r.to_a
      end

      put_links

      @response_tree
    end

    # Call this with  name & block - create a named singular object
    # creating its fields inside the block
    def object(*args_or_name, block)
      def_args = extract_definition_args(args_or_name)
      new_source = field_value(def_args)
      return unless check_when(def_args, new_source)
      return unless version_wanted(def_args)

      @source_stack.push(@current_source)
      @current_source = new_source || @current_source

      if def_args.key?(:name) || def_args.key?(:dynamic_key)
        @put_stack.push(@put_stack.last[def_args[:dynamic_key] || def_args[:name]] = new_h)
        @link_stack.push([])

        block.call(@current_source)

        put_links
        @put_stack.pop
      elsif def_args[:inline_always]
        block.call @current_source
      else
        raise 'object requires either a name or inline_always: true'
      end

      @current_source = @source_stack.pop
    end

    # call this with either:
    # name and block - create a named array of objects creating fields inside the block
    # name, value and block - as above but call the block with either one value (if scalar), or each of its items (if non-hash Enumerable)
    # hash of options including :name, :value
    #  :compact - remove any fields with nil values
    #  :hashed - produce a hash rather than a collection. The hash key is defined with {#hash_key}
    def objects(*args_or_name, block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name
      new_source = field_value(def_args) || @current_source
      return unless check_when(def_args, new_source)
      return unless version_wanted(def_args)

      values = new_source
      # puts "args_or_name=#{args_or_name},\n def_args=#{def_args}, objects=#{values}"

      @hash_stack.push(@hash_key ||= nil)
      objects_result = def_args[:hashed] ? new_h : []
      @put_stack.last[def_args[:name]] = objects_result

      # puts "+++objects, name=#{def_args[:name]}, @hash_key=#{@hash_key}, @put_stack = #{@put_stack}"

      values.each do |value|
        @source_stack.push(@current_source)
        @current_source = value
        @put_stack.push(object_hash = new_h)
        @link_stack.push([])

        if value.nil?
          block.call
        elsif value.is_a?(Array)
          block.call(*value)
        else
          block.call value
        end

        put_links

        if objects_result.is_a?(Hash)
          raise "No hash_key defined for hashed objects #{def_args[:name]}" unless @hash_key

          # puts "Set objects_result[#{@hash_key}] = #{object_hash}"
          objects_result[@hash_key] = object_hash
        else
          objects_result << object_hash
          objects_result.compact! if def_args[:compact]
        end

        @put_stack.pop
        @current_source = @source_stack.pop
      end

      @hash_key = @hash_stack.pop
      # puts "--- objects, name=#{def_args[:name]}, @hash_key=#{@hash_key}, @put_stack = #{@put_stack}"
    end

    # call this with either:
    #  name only - create a field with value @current_value[:name]
    #  name and block - create a field whose value is the block return
    #  name and value - create a field with a value
    #  hash of options including :name, :value
    def field(*args_or_name, block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name

      return unless check_when(def_args, @current_source)
      return unless version_wanted(def_args)

      value = field_value(def_args, block)
      # Rails.logger.debug "Field #{def_args[:name]} <= #{value} current_source=#{@current_source}"
      put_field def_args[:name], value
    end

    # Define the hash key for an objects(:hashed)
    def hash_key(*args, block)
      # TODO: can't be nested
      def_args = extract_definition_args_nameless(args)

      return unless check_when(def_args, @current_source)
      return unless version_wanted(def_args)

      @hash_key = field_value(def_args, block)
      # puts "hash_key = #{@hash_key}"
    end

    # call this with either:
    #  name and block - create a reference to the object created by the block, which must include an ID field
    #  hash of options including :name, :value
    #   type: creates a polymorphic relation and specify the name of the type
    #   for: for a polymorphic relation, provide the type that is being requested/generated. (This will usually be from model data or request)
    #
    def reference(*args_or_name, block)
      # Check the args
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name
      # puts "reference #{def_args}"
      name = def_args[:name]
      return unless version_wanted(def_args)

      raise "polymorphic reference #{name} must specify :type and :for" if def_args.key?(:for) ^ def_args.key?(:type)

      if def_args.key?(:for) && def_args.key?(:type)
        ref_type = def_args[:type]
        return unless ref_type.to_s == def_args[:for].to_s.camelize # Skip where the polymorph isn't us
      end

      # This reference is to be generated

      @put_stack.push(reference_record = new_h)
      block.call
      @put_stack.pop

      raise "reference #{name} must yield a block returning hash" unless reference_record.is_a?(Hash)
      raise "reference #{name} must yield a hash with an :id" unless reference_record.key?(:id)

      unless def_args[:link_id] == false
        ref_id = reference_record[:id]
        put_field "#{name}_id", ref_id
      end

      if def_args.key?(:type)
        put_field "#{name}_type", ref_type if def_args.key?(:generate_from_type) # TODO: doc
        ref_key = ref_type.to_s.underscore.pluralize
      else
        ref_key = name
      end

      (@references[ref_key] ||= Set.new) << reference_record
    end

    # Call this with:
    # :key => link key, either self or an endpoint
    # :path => path to expand into link, include parameters with :param
    # shorthand one param is :key, two is :key, :path
    def link(*link_params)
      raise "link takes 1/2 params, not: #{link_params}" unless (1..2).cover? link_params.size

      link_def = if link_params.size == 1 && link_params.first.is_a?(Hash)
                   link_params.first
                 else
                   Hash[link_params.each_with_index.map { |p, idx| [%i[key path][idx], p] }]
                 end

      raise 'link to an endpoint apart from :self needs a path' unless link_def[:key] == :self || link_def[:path]

      link_def[:link_source_vars] = @current_source.clone
      @link_stack.last << link_def
    end

    def query(block)
      @query_block = block
    end

    def return_no_content
      @status_code = 204
      @status_error_info = 'No content'
    end

    def return_error(status_code, error_info)
      @status_code = status_code
      @status_error_info = error_info
    end

    # private

    def new_h
      {}.with_indifferent_access
    end

    def put_field(name, value)
      # puts "put_field name=#{name}, value=#{value} value_class=#{value.class.to_s}"
      @put_stack.last[name] = value
    end

    def field_value(def_args, block = nil)
      src_value = if block.present?
                    block.call @current_source
                  elsif def_args.key?(:value)
                    def_args[:value]
                  elsif def_args.key?(:values)
                    def_args[:values]
                  else
                    name = def_args[:source] || def_args[:name]
                    if name
                      access_member_somehow(@current_source, name)
                    else
                      @current_source
                    end
                  end

      cast_value(src_value, def_args[:type], def_args[:precision])
    end

    def cast_value(src, type, precision)
      # puts "cast_value #{src}, type #{type.to_s}"
      case type&.to_s
      when nil
        src
      when 'boolean_type'
        if src.nil?
          nil
        else
          !!src
        end
      when 'boolean_strict'
        !!src
      when 'BigDecimal', 'Float'
        if precision
          src&.to_f&.round(precision)
        else
          src&.to_f # we want Bigdecimal as a numeric
        end
      when 'Integer'
        src&.to_i
      else
        src
      end
    end

    def access_member_somehow(object, name)
      return nil if object.nil?

      if object.is_a?(Hash)
        return object[name.to_sym] if object.key?(name.to_sym)
        return object[name.to_s] if object.key?(name.to_s)
        return nil
      end

      return object.send(name.to_sym) if object.respond_to?(name.to_sym)

      query_name = "#{name}?".to_sym
      return object.send(query_name) if object.respond_to?(query_name)

      nil
    end

    def controller_base_url
      raise 'path not defined in endpoint' unless source_definition.endpoint_info[:path]

      path = source_definition.endpoint_info[:path].gsub(/\/$/, '') # remove trailing slash
      path_matcher = Regexp.new(path.gsub(/\/:\w+/, '\/[^\/]+')) # converts `/user/:user_id` into `/user/[^\/]+`

      # puts "Using matcher #{path_matcher} on #{controller_url}"
      matches = controller_url.match(path_matcher)
      return controller_url unless matches

      controller_url[0...matches.begin(0)]
    end

    def expand_self_path(path, defined_param_names)
      # puts "expand_self_path path=#{path}, defined_param_names=#{defined_param_names}, controller_params=#{controller_params}"
      subst_uri, used_params = substitute_link_path_params(path, {})

      query_params = controller_params.clone
      query_params = query_params.to_unsafe_hash if query_params.respond_to?(:to_unsafe_hash)
      query_params.delete_if { |k, _v| used_params.include?(k.to_sym) || !defined_param_names.include?(k.to_sym) }

      src_query_hash = CGI.parse(subst_uri.query || '').with_indifferent_access
      subst_query = src_query_hash.merge(query_params)

      expanded = expand_uri_with_host(subst_uri)
      expanded += "?#{subst_query.to_query}" unless subst_query.empty?
      expanded
    end

    def expand_link_path(path, source_vars)
      # puts "expand_link_path path=#{path}, controller_params=#{controller_params}"
      subst_uri, _used_params = substitute_link_path_params(path, source_vars)

      expanded = expand_uri_with_host(subst_uri)
      expanded += "?#{subst_uri.query}" if subst_uri.query
      expanded
    end

    def expand_uri_with_host(subst_uri)
      expanded = controller_base_url
      expanded += '/' unless expanded[-1] == '/' || subst_uri.path[0] == '/'
      expanded + subst_uri.path
    end

    def substitute_link_path_params(path, vars)
      subst_path = path.dup
      used_params = []

      controller_params.each do |pname, pvalue|
        subex = /:#{pname}([^\w]|\z)/
        next unless subst_path.match?(subex)

        # Since we're building a URL, we need to ensure it's encoded properly.
        # Fortunately, it appears Ruby will unencode url parameters for us, so we don't need to unencode `foo%20bar` here.
        # When this is used later, we need the encoded value.
        escaped_value = ::CGI.escape(pvalue.to_s)
        subst_path.gsub!(subex, "#{escaped_value}\\1")
        used_params << pname.to_sym
      end

      loop do
        matched_param = subst_path.match(/:(\w+)/)
        break unless matched_param

        param_name = matched_param[1]
        subst_value = access_member_somehow(vars, param_name)
        raise "Link path contains unsubstituted param #{param_name} in #{subst_path}" unless subst_value

        subst_path.sub!(matched_param[0], subst_value.to_s)
      end

      # puts "Made path #{subst_path}"
      subst_uri = ::URI.parse(subst_path)
      [subst_uri, used_params]
    end

    private

    def check_when(def_args, source)
      return true unless def_args.key?(:when)

      return !!source if def_args[:when]&.is_a?(Symbol) && def_args[:when] == :source_present

      !!def_args[:when]
    end

    def put_links
      link_defs = @link_stack.pop || []
      links = link_defs.map do |link_def|
        expanded_link = if link_def[:key] == :self
                          expand_self_path(source_definition.endpoint_info[:path],
                                           source_definition.endpoint_info[:params].map { |p| p[:name].to_sym })
                        else
                          expand_link_path(link_def[:path], link_def[:link_source_vars])
                        end
        [link_def[:key], expanded_link]
      end.to_h

      @put_stack.last[:links] = links unless links.empty?
    end

    def params_to_permit
      make_param_arg(source_definition.endpoint_info[:params])
    end

    def params_to_require
      required_params = source_definition.endpoint_info[:params].reject { |p| p[:optional] }
      return param_group_names if required_params.empty?
      make_param_arg(required_params)
    end

    def param_group_names
      source_definition.endpoint_info[:params].map do |param_def|
        keys = param_def[:name].to_s.split('/').map(&:to_sym)
        next nil unless keys.size > 1
        keys.first
      end.compact.uniq
    end

    def make_param_arg(param_defs)
      res = []

      param_defs.each do |param_def|
        keys = param_def[:name].to_s.split('/').map(&:to_sym)
        if keys.size == 1
          res << keys.first
          next
        end

        raise "Unsupported nesting of depth > 2 at #{param_def[:name]}" if keys.size > 2

        group = keys.first
        k = keys.second

        raise "At #{param_def[:name]}, #{group} is used for plain and grouped parameters, which wont work" if res.include?(group)

        res << {} unless res.last.is_a?(Hash)
        res.last[group] ||= []
        res.last[group] << k
      end

      res
    end
  end
end
