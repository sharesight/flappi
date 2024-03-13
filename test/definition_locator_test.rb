# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'examples2/exercise1'
require_relative 'examples2/exercise5'

class ::Flappi::DefinitionLocatorTest < MiniTest::Test
  context 'locate_class' do
    should 'Locate a valid definition' do
      located_class = Flappi::DefinitionLocator.locate_class('Exercise1', 'v2.0')
      assert_equal Examples::Exercise1, located_class
    end

    should 'Locate a valid definition by order in the definition_paths config' do
      # eg. definition_paths = { 'v3.0': ['examples', 'examples2'] } - this test targets the first `examples` and ignores the second.
      located_class = Flappi::DefinitionLocator.locate_class('Exercise1', 'v3.0')
      assert_equal Examples::Exercise1, located_class
      assert_equal 'examples', located_class.definition_source
    end

    should 'Locate a valid version as a fallback by order in the definition_paths config' do
      # eg. definition_paths = { 'v3.0': ['examples', 'examples2'] } - this test targets the `examples2` as it does not exist in `examples`.
      located_class = Flappi::DefinitionLocator.locate_class('Exercise5', 'v3.0')
      assert_equal Examples2::Exercise5, located_class
      assert_equal 'examples2', located_class.definition_source
    end

    should 'Raise an error with a missing version' do
      located_class = nil
      ex = assert_raises RuntimeError do
        located_class = Flappi::DefinitionLocator.locate_class('Exercise1', 'v-bad-version')
      end

      assert_equal 'Unable to find a definition_path for v-bad-version.', ex.message
      refute located_class
    end

    should 'Raise an error when no valid definition' do
      located_class = nil
      ex = assert_raises RuntimeError do
        located_class = Flappi::DefinitionLocator.locate_class('DoesntExist', 'v2.0')
      end

      assert_match(/Endpoint DoesntExist is not defined to Flappi/, ex.message)
      assert_match(/uninitialized constant Examples::DoesntExist/, ex.message)
      refute located_class
    end
  end
end
