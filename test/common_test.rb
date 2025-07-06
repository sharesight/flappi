# frozen_string_literal: true

require_relative 'test_helper'

class ::Flappi::ResponseBuilderTest < Minitest::Test
  context 'when extended' do
    setup do
      @common_test = Object.new
      @common_test.extend(Flappi::Common)
    end

    context 'extract_definition_args' do
      should 'return an empty hash for empty input' do
        assert_empty(@common_test.extract_definition_args([]))
      end

      should 'raise an exception for four positional args' do
        exception = assert_raises(RuntimeError) { @common_test.extract_definition_args(['name', 2, 3, { option: 666 }]) }
        assert_equal 'Unexpected >3 positional arguments at ["name", 2, 3, {:option=>666}]', exception.message
      end

      should 'extract a single name from an array' do
        assert_equal({ 'name' => :a }, @common_test.extract_definition_args([:a]))
      end

      should 'extract a single name from a scalar' do
        assert_equal({ 'name' => :a }, @common_test.extract_definition_args(:a))
      end

      should 'extract a name and value' do
        assert_equal({ 'name' => :a, 'value' => 101 }, @common_test.extract_definition_args([:a, 101]))
      end

      should 'pass through a hash' do
        assert_equal({ 'name' => :a, 'value' => 101 }, @common_test.extract_definition_args(name: :a, value: 101))
      end
    end

    context 'extract_definition_args_nameless' do
      should 'return an empty hash for empty input' do
        assert_empty(@common_test.extract_definition_args_nameless([]))
      end

      should 'raise an exception for three positional args' do
        exception = assert_raises(RuntimeError) { @common_test.extract_definition_args_nameless(['name', 2, { option: 666 }]) }
        assert_equal 'Unexpected >2 positional arguments at ["name", 2, {:option=>666}]', exception.message
      end

      should 'extract a single value from an array' do
        assert_equal({ 'value' => 111 }, @common_test.extract_definition_args_nameless([111]))
      end

      should 'extract a single value from a scalar' do
        assert_equal({ 'value' => 111 }, @common_test.extract_definition_args_nameless(111))
      end

      should 'pass through a hash' do
        assert_equal({ 'value' => 101, 'option' => 'extra' }, @common_test.extract_definition_args_nameless(value: 101, option: 'extra'))
      end

      should 'pass through a hash in an array' do
        assert_equal({ 'value' => 101, 'option' => 'extra' }, @common_test.extract_definition_args_nameless([{ value: 101, option: 'extra' }]))
      end

      should 'extract value and hash' do
        assert_equal({ 'value' => 101, 'option' => 'extra' }, @common_test.extract_definition_args_nameless([101, { option: 'extra' }]))
      end
    end

    context 'require_arg' do
      should 'do nothing if arg is defined' do
        @common_test.require_arg({ a: 1, b: 2, c: 3 }, :c)
      end

      should 'raise exception if arg is not defined' do
        exception = assert_raises(RuntimeError) { @common_test.require_arg({ a: 1, b: 2, c: 3 }, :q) }
        assert_equal 'Expecting q to be defined (in a, b, c)', exception.message
      end
    end

    context 'name_for_type' do
      should 'get a class name' do
        assert_equal 'ResponseBuilderTest', @common_test.name_for_type(self.class)
      end

      should 'treat nil as stringy' do
        assert_equal 'String', @common_test.name_for_type(nil)
      end

      should 'handle :boolean_type' do
        assert_equal 'Boolean', @common_test.name_for_type(:boolean_type)
      end

      should 'pass strings through' do
        assert_equal 'Wombat', @common_test.name_for_type('Wombat')
      end

      should 'fail neatly' do
        assert_equal '**Unknown**', @common_test.name_for_type(:symbol)
      end
    end
  end
end
