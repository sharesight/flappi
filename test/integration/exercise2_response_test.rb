# frozen_string_literal: true
require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise2_versioned'
require_relative '../examples/v2_version_plan'
require_relative '../examples/exercise_model'

module Examples
  class Exercise2VersionedController
    attr_accessor :params
    attr_accessor :last_render_params

    def show
      Flappi.build_and_respond(self)
    end

    def request
      OpenStruct.new(query_parameters: params)
    end

    def respond_to
      yield JsonFormatter.new
    end

    def render(params)
      self.last_render_params = params
    end
  end
end

module Integration
  class Exercise2ResponseTest < MiniTest::Test
    context 'Response to Exercise2' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = Examples::V2VersionPlan
        end
      end

      should 'respond with version 2.1 result' do
        controller = Examples::Exercise2VersionedController.new
        controller.params = { required: 2.718, version: 'V2.1.0-mobile' }
        response = controller.show

        assert_equal({ 'all' => 'all_versions', 'v2_1_only' => 2.1 },
                     response)
      end

      should 'respond with version 2.0 result' do
        controller = Examples::Exercise2VersionedController.new
        controller.params = { required: 3.142, version: 'V2.0-mobile' }
        response = controller.show

        assert_equal({ 'all' => 'all_versions', 'v2_0_only' => 2.0 },
                     response)
      end

      should 'fail for missing required parameter' do
        controller = Examples::Exercise2VersionedController.new
        controller.params = { version: 'V2.0-mobile' }
        response = controller.show

        refute response
        assert_equal({ json: '{"error":"Parameter required is required"}',
                       text: 'Parameter required is required', status: :not_acceptable },
                     controller.last_render_params)
      end

      should 'fail when parameter fails validation' do
        controller = Examples::Exercise2VersionedController.new
        controller.params = { required: 123.4, version: 'V2.0-mobile' }
        response = controller.show

        refute response
        assert_equal({ json: '{"error":"Parameter required failed validation: Parameter v outside range 0..10"}',
                       text: 'Parameter required failed validation: Parameter v outside range 0..10', status: :not_acceptable },
                     controller.last_render_params)
      end

      should 'fail for unsupported version' do
        controller = Examples::Exercise2VersionedController.new
        controller.params = { required: 1.414, version: 'V1.9' }
        response = controller.show

        refute response
        assert_equal({ json: '{"error":"Version V1.9 not supported by endpoint"}',
                       text: 'Version V1.9 not supported by endpoint', status: :not_acceptable },
                     controller.last_render_params)
      end
    end
  end
end
