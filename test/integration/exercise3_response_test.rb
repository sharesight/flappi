# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../examples/exercise3_my_method'
require_relative '../examples/version_plan'
require_relative '../examples/exercise_model'

module Examples
  class Exercise3Controller < ExampleController
    def my_method
      Flappi.build_and_respond(self, :my_method)
    end

    def request
      OpenStruct.new(query_parameters: params, raw_post: 'This is raw post data')
    end
  end
end

module Integration
  class Exercise3ResponseTest < Minitest::Test
    context 'Response to Exercise3' do
      should 'respond with ok to posted data' do
        controller = Examples::Exercise3Controller.new
        controller.params = { required: 2.718, version: 'v2.1.0-mobile' }
        response = controller.my_method

        assert_equal({ 'ok' => true },
                     response)
      end
    end
  end
end
