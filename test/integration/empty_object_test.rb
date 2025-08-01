# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../examples/empty_object'

module Examples
  class EmptyObjectController < ExampleController
  end
end

module Integration
  class EmptyObjectTest < Minitest::Test
    context 'Response to EmptyObject' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'respond with an empty object' do
        controller = Examples::EmptyObjectController.new
        response = controller.show

        refute_equal(:no_content, controller.last_head_params)
        assert_empty(response)
      end
    end
  end
end
