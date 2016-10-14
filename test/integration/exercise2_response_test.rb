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
      return OpenStruct.new(query_parameters: params)
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
        controller.params = { version: 'V2.1.0-mobile' }
        response = controller.show

        assert_equal( {json: { "all"=>'all_versions', 'v2_1_only' => 2.1 },
            :status=>:ok},
            response)
      end
    end
  end
end
