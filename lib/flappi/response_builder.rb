# Build an API response from a definition
require 'uri'
require 'active_support/core_ext/hash/conversions'
require 'active_support/core_ext/hash/indifferent_access'

module Flappi
  class ResponseBuilder

    include Common

    attr_accessor :controller_params
    attr_accessor :controller_query_parameters
    attr_accessor :controller_url
    attr_reader :query_block

    def initialize
      @query_block = nil
      @link_defs = nil
    end

    # Call this with a block that builds the API response
    def build(options, &_block)
      # puts "response_builder::build, class= #{self.class} self="; pp self;

      base_object = nil
      if @query_block
        # We have a query block defined, call it to get the model object
        base_object = @query_block.call(controller_params)

        # puts "ResponseBuilder::build - query_block got "; pp base_object

      elsif options.key?(:type)
        # construct a model of type with the parameters
        # which we should have by virtue of being mixed into the controller
        base_object = options[:type].where(controller_params)
      end

      @response_tree = new_h
      @put_stack = [@response_tree]
      @references = new_h
      @current_source = base_object

      if base_object
        yield @current_source
      else
        yield
      end

      @current_source = nil

      links = Hash[(@link_defs || []).map do |link_def|
          expanded_link = if link_def[:key]==:self
            expand_link_path(source_definition.endpoint_info[:path], controller_query_parameters, true)
          else
            expand_link_path(link_def[:path], controller_query_parameters, false)
          end
          [link_def[:key], expanded_link]
      end]

      @response_tree[:links] = links unless links.empty?

      @response_tree.merge(@references)
    end

    # Call this with  name & block - create a named singular object
    # creating its fields inside the block
    def object(*args_or_name, block)
      def_args = extract_definition_args(args_or_name)
      return if def_args.key?(:when) && !def_args[:when]

      @current_source = def_args[:value] || @current_source

      if def_args.key? :name
        @put_stack.push(@put_stack.last[def_args[:name]] = new_h)
        block.call @current_source
        @put_stack.pop
      elsif def_args[:inline_always]
        block.call @current_source
      else
        raise "object requires either a name or inline_always: true"
      end

      @current_source = nil
    end

    # call this with either:
    # name and block - create a named array of objects creating fields inside the block
    # name, value and block - as above but call the block with either one value (if scalar), or each of its items (if array)
    # hash of options including :name, :value
    #  :compact - remove any fields with nil values
    # TODO: Enumerable not Array ?
    def objects(*args_or_name, block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name
      return if def_args.key?(:when) && !def_args[:when]

      values = def_args[:value] || def_args[:values] || @current_source
      # puts "args_or_name=#{args_or_name},\n def_args=#{def_args}, objects=#{values}"
      # puts "objects - put_stack=#{@put_stack}"

      @put_stack.last[def_args[:name]] = objects_array = []

      values.each do |value|
        @current_source = value
        @put_stack.push(object_hash = new_h)
        if value.nil?
          block.call
        elsif value.is_a?(Array)
          block.call(*value)
        else
          block.call value
        end
        objects_array << object_hash
        objects_array.compact! if def_args[:compact]
        @put_stack.pop
        @current_source = nil
      end
    end

    # call this with either:
    #  name only - create a field with value @current_value[:name]
    #  name and block - create a field whose value is the block return
    #  name and value - create a field with a value
    #  hash of options including :name, :value
    def field(*args_or_name, block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name
      require_arg def_args, :name

      value = field_value(def_args, block)
      # Rails.logger.debug "Field #{def_args[:name]} <= #{value} current_source=#{@current_source}"
      put_field def_args[:name], value
    end

    # call this with either:
    #  name and block - create a reference to the object created by the block, which must include an ID field
    #  hash of options including :name, :value
    #   type: creates a polymorphic relation and specify the name of the type
    #   for: for a polymorphic relation, provide the type that is being requested/generated. (This will usually be from model data or request)
    #
    # TODO: Polymorphism needs to be able to absolutely specify fields for doco
    def reference(*args_or_name, block)
      # Check the args
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name
      name = def_args[:name]

      if def_args.key?(:for) ^ def_args.key?(:type)
        raise "polymorphic reference #{name} must specify :type and :for"
      end

      if def_args.key?(:for) && def_args.key?(:type)
        ref_type = def_args[:type]
        return unless ref_type == def_args[:for]  # Skip where the polymorph isn't us
      end

      # This reference is to be generated

      @put_stack.push(reference_record = new_h)
      block.call
      @put_stack.pop

      raise "reference #{name} must yield a block returning hash" unless reference_record.is_a?(Hash)
      raise "reference #{name} must yield a hash with an :id" unless reference_record.key?(:id)

      ref_id = reference_record[:id]
      put_field "#{name}_id", ref_id

      if def_args.key?(:type)
        put_field "#{name}_type", ref_type
        ref_key = ref_type.to_s.pluralize
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
      link_def = if link_params.is_a? Array
        raise "link takes 1/2 params, not: #{link_params}" unless (1..2).cover? link_params.size
        Hash[link_params.each_with_index.map {|p, idx| [[:key, :path][idx], p]}]
      else
        link_params
      end

      raise "link to an endpoint apart from :self needs a path" unless link_def[:key]==:self || link_def[:path]
      (@link_defs ||= []) << link_def
    end

    def query(&block)
      @query_block = block
    end

    # private

    def new_h
      {}.with_indifferent_access
    end

    def put_field(name, value)
      # puts "put_field name=#{name}, value=#{value} value_class=#{value.class.to_s}"
      @put_stack.last[name] = value
    end

    def field_value(def_args, block)
      src_value = if block.present?
        block.call @current_source
      elsif def_args.key?(:value)
        def_args[:value]
      else
        access_member_somehow(@current_source, def_args[:name])
      end

      cast_value(src_value, def_args[:type], def_args[:precision])
    end

    def cast_value(src, type, precision)
     # puts "cast_value #{src}, type #{type.to_s}"
      case type&.to_s
        when nil
          src
        when 'BOOLEAN'
          if src.nil?
            nil
          else
            src ? true : false
          end
        when 'BigDecimal', 'Float'
          if precision
            src&.to_f&.round(precision)
          else
            src&.to_f  # we want Bigdecimal as a numeric
          end
        when 'Integer'
          src&.to_i
        else
          src
      end
    end

    def access_member_somehow(object, name)
      if object.is_a?(Hash)
        return object[name.to_sym] if object.key?(name.to_sym)
        return object[name.to_s] if object.key?(name.to_s)
        return nil
      end

      return object.send(name.to_sym)
    end

    def controller_base_url
      raise 'path not defined in endpoint' unless source_definition.endpoint_info[:path]
      path_matcher = Regexp.new source_definition.endpoint_info[:path].gsub(/\/:\w+\//, '\/[^\/]+\/')

      # puts "Using matcher #{path_matcher} on #{controller_url}"
      matches = controller_url.match(path_matcher)
      return controller_url unless matches

      controller_url[0...matches.begin(0)]
    end

    def expand_link_path(path, passed_query_params, subst_all_query_params)
      subst_path = path
      used_params = []
      controller_params.each do |pname, pvalue|
        subex = /:#{pname}([^\w]|\z)/
        #puts "Try #{pname}=#{pvalue}, subex=#{subex} on #{subst_path}"
        if subst_path =~ subex
          subst_path.gsub!( subex, "#{pvalue}\\1" )
          used_params << pname
        end
      end

      #puts "Made path #{subst_path}"
      subst_uri = ::URI.parse(subst_path)
      raise "Link path contains unsubstituted params #{path}" if subst_uri.path =~ /:\w+/

      query_params = passed_query_params.clone
      query_params.delete_if {|k,_v| used_params.include? k }

      src_query_hash = CGI::parse(subst_uri.query || '').with_indifferent_access
      puts "src_query_hash=#{src_query_hash}, subst_all_query_params=#{subst_all_query_params}, query_params=#{query_params}"
      if subst_all_query_params
        subst_query = src_query_hash.merge(query_params)
      else
        subst_query = Hash[src_query_hash.map do |k,v|
          query_params.key?(k.to_sym) ? [k,v.first] : nil
        end.compact]
      end

      expanded = controller_base_url + subst_uri.path
      expanded += "?#{subst_query.to_query}" unless subst_query.empty?

      puts "expanded=#{expanded}, subst_query=#{subst_query}"
      expanded
    end
  end
end
