# DSL for API construction
# this defines methods which can be used to construct API responses, docs, etc


module Flappi
  module Definition

    include Common

    BOOLEAN = :boolean_type

    attr_reader :delegate
    attr_accessor :version_plan
    attr_accessor :defining_class

    def endpoint_info
      @endpoint_info ||= { params: [] }
    end

    def endpoint_simple_name
      defining_class.name.match(/::(\w+)$/).captures.first
    end

    def supported_versions
      @version_rule.nil? ?
          version_plan.available_version_definitions :
          version_plan.expand_version_rule(@version_rule)
    end

    def document_as_version
      return '0.0.0' unless version_plan

      return version_plan.minimum_version if @version_rule.nil?
      supported_versions = version_plan.expand_version_rule(@version_rule)
      return version_plan.minimum_version if supported_versions.blank?

      raise "Multiple versions supported #{supported_versions} - not allowed by documenter as yet in #{endpoint_simple_name}" if supported_versions.size > 1
      supported_versions.first
    end

    def mode=(mode)
      @delegate = "Flappi::#{mode.to_s.camelize}Builder".constantize.new
      @delegate.source_definition = self
    end

    def controller_params=(p)
      @delegate.controller_params = p if @delegate.respond_to? :controller_params=
    end

    def controller_query_parameters=(p)
      @delegate.controller_query_parameters = p if @delegate.respond_to? :controller_query_parameters=
    end

    def controller_url=(p)
      @delegate.controller_url = p if @delegate.respond_to? :controller_url=
    end

    # Call this with a block that builds the API response
    def build(options={}, &block)
      @delegate.build options, &block
    end

    def include_when(test)
      yield if test
    end

    # Call this with  name & block - create a named singular object
    # creating its fields inside the block
    def object(*args_or_name, &block)
      @delegate.object(*args_or_name, block)
    end

    # call this with either:
    # name and block - create a named array of objects creating fields inside the block
    # name, value and block - as above but call the block with either one value (if scalar), or each of its items (if array)
    # hash of options including :name, :value
    #  compact - remove any fields with nil values
    def objects(*args_or_name, &block)
      @delegate.objects(*args_or_name, block)
    end

    # call this with either:
    #  name only - create a field with value @current_value[:name]
    #  name and block - create a field whose value is the block return
    #  name and value - create a field with a value
    #  hash of options including :name, :value
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

    def link(*link_params)
      @delegate.link(*link_params) if @delegate.respond_to? :link
    end

    # Endpoint methods
    def version(version_rule)
      raise "No version plan is defined - cannot use 'version'" unless version_plan
      @version_rule = version_rule
    end

    def group(v)
      endpoint_info[:group] = v
    end

    def method(v)
      endpoint_info[:method] = v
    end

    def path(v)
      endpoint_info[:path] = v
    end

    def title(v)
      endpoint_info[:title] = v
    end

    def description(v)
      endpoint_info[:description] = v
    end

    def response_example(v)
      endpoint_info[:response_example] = v
    end

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

    def query(&block)
      @delegate.query(block)
    end

  end
end
