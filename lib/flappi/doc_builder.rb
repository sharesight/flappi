# frozen_string_literal: true

# Build API documentation from a definition
require 'active_support/inflector'

module Flappi
  class DocBuilder
    include Common

    attr_accessor :version_plan
    attr_accessor :requested_version

    def build(_options, &_block)
      @object_path = []
      @document = []
      @references = []
      @doc_targets = [@document]

      yield Flappi::BuilderFactory::DocumentingStub.new # More will happen

      # pp @document
      # pp @references

      @document + @references
    end

    def object(*args_or_name, block)
      object_one_or_many(*args_or_name, false, block)
    end

    def objects(*args_or_name, block)
      object_one_or_many(*args_or_name, true, block)
    end

    def field(*args_or_name, _block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name

      return unless version_wanted(def_args)

      if def_args.key?(:when)
        # The when clause can call undefined code at doc time
        ignore = !def_args[:when] rescue false # rubocop:disable Style/RescueModifier
        return if ignore
      end

      # handle dynamic field names by bracketing either 'doc_name' or the word 'dynamic'
      # with an underscore
      use_name = def_args[:name]
      use_name = '_' + (def_args[:doc_name] || 'dynamic') + '_' if def_args[:name].is_a?(Flappi::BuilderFactory::DocumentingStub)

      # puts "field @object_path=#{get_object_path} def_args=#{def_args}"
      @doc_targets.last << { name: peek_object_path.clone + [use_name],
                             type: name_for_type(def_args[:type]),
                             description: def_args[:doc] }

      @id_type = name_for_type(def_args[:type]) if use_name == '_id'
    end

    def reference(*args_or_name, block)
      def_args = extract_definition_args(args_or_name)
      require_arg def_args, :name
      return unless version_wanted(def_args)

      # puts "reference @object_path=#{get_object_path} def_args=#{def_args}"
      @doc_targets.push @references
      reference_name = def_args[:type].underscore.pluralize
      push_object_path(reference_name, true)
      @doc_targets.last << { name: [reference_name],
                             type: name_for_type(def_args[:type]) + '[]',
                             description: def_args[:doc] }

      block.call Flappi::BuilderFactory::DocumentingStub.new
      pop_object_path
      @doc_targets.pop

      # And document the id field that links to this block
      if def_args[:from_doc]
        from_id = def_args[:name].to_s + '_id'
        unless (@sent_reference_ids ||= {})[:from_id]
          @doc_targets.last << { name: peek_object_path.clone + [from_id],
                                 type: @id_type,
                                 description: def_args[:from_doc] }
          @sent_reference_ids[:from_id] = true
        end
      end
    end

    def query(block); end

    private

    def peek_object_path
      first_ref_index = @object_path.find_index { |opi| opi[:is_reference] }

      return @object_path.map { |opi| opi[:element] } unless first_ref_index

      @object_path.slice(first_ref_index..-1).map { |opi| opi[:element] }
    end

    def push_object_path(element_name, is_reference)
      raise 'Cannot nest reference elements' if is_reference && @object_path.find { |opi| opi[:is_reference] }

      @object_path.push(element: element_name, is_reference: is_reference)
    end

    def pop_object_path
      @object_path.pop
    end

    def object_one_or_many(*args_or_name, is_many, block)
      def_args = extract_definition_args(args_or_name)
      raise 'Must specify name, inline_always or dynamic_key' unless %i[name inline_always dynamic_key] & def_args.keys
      return unless version_wanted(def_args)

      # puts "object_one_or_many @object_path=#{get_object_path} def_args=#{def_args}"
      if def_args[:name]
        # If an object isn't named, we don't ApiDoc it
        push_object_path(def_args[:name], false)
        @doc_targets.last << { name: peek_object_path.clone,
                               type: name_for_type(def_args[:type]) + (is_many ? '[]' : ''),
                               description: def_args[:doc] }
      end

      block.call Flappi::BuilderFactory::DocumentingStub.new

      pop_object_path if def_args[:name]
    end
  end
end
