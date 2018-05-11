# frozen_string_literal: true

require_relative 'test_helper'

class ::Flappi::DefinitionLocatorTest < MiniTest::Test
  context 'locate_class' do
    should 'Locate a valid definition' do
      Flappi.configure do |conf|
        conf.definition_paths = ['examples']
      end
      located_class = Flappi::DefinitionLocator.locate_class('Exercise1')
      assert_equal Examples::Exercise1, located_class
    end

    should 'Raise an error when no valid definition' do
      Flappi.configure do |conf|
        conf.definition_paths = ['examples']
      end

      located_class = nil
      ex = assert_raises RuntimeError do
        located_class = Flappi::DefinitionLocator.locate_class('DoesntExist')
      end

      assert_equal 'Endpoint DoesntExist is not defined to Flappi: Could not load Examples::DoesntExist because uninitialized constant Examples::DoesntExist was raised',
                   ex.message
      refute located_class
    end
  end
end
