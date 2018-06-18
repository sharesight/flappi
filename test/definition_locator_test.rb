# frozen_string_literal: true

require_relative 'test_helper'

class ::Flappi::DefinitionLocatorTest < MiniTest::Test
  context 'locate_class' do
    should 'Locate a valid definition' do
      Flappi.configure do |conf|
        conf.definition_paths = {
          'v2.0' => 'examples',
          'v3.0' => 'examples'
        }
      end
      located_class = Flappi::DefinitionLocator.locate_class('Exercise1', 'v2.0')
      assert_equal Examples::Exercise1, located_class
    end

    should 'Raise an error with a missing version' do
      Flappi.configure do |conf|
        conf.definition_paths = {
          'v2.0' => 'examples',
          'v3.0' => 'examples'
        }
      end

      located_class = nil
      ex = assert_raises RuntimeError do
        located_class = Flappi::DefinitionLocator.locate_class('Exercise1', 'v-bad-version')
      end

      assert_equal 'Unable to find a definition_path for v-bad-version.', ex.message
      refute located_class
    end

    should 'Raise an error when no valid definition' do
      Flappi.configure do |conf|
        conf.definition_paths = {
          'v2.0' => 'examples',
          'v3.0' => 'examples'
        }
      end

      located_class = nil
      ex = assert_raises RuntimeError do
        located_class = Flappi::DefinitionLocator.locate_class('DoesntExist', 'v2.0')
      end

      assert_equal 'Endpoint DoesntExist is not defined to Flappi: Could not load Examples::DoesntExist because uninitialized constant Examples::DoesntExist was raised', ex.message
      refute located_class
    end
  end
end
