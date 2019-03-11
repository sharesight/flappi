# frozen_string_literal: true

require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise8'

module Examples
  class Exercise8Controller < ExampleController
    def request
      OpenStruct.new(query_parameters: params, url: 'http://test.api/exercise8')
    end
  end
end

module Integration
  class Exercise8ResponseTest < MiniTest::Test
    context 'Response to Exercise8' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end

        @controller = Examples::Exercise8Controller.new
      end

      should 'respond when required param present' do
        @controller.params = { required: 1 }
        response = @controller.show

        assert_equal({ 'a' => 'ok' }, response)
      end

      should 'fail when required param missing' do
        @controller.params = {}
        response = @controller.show
        refute response

        assert_equal({:json=>"{\"error\":\"Parameter required is required\"}",
                      :plain=>"Parameter required is required",
                      :status=>:not_acceptable}, @controller.last_render_params)
      end

      should 'fail when unrecognized parameter' do
        @controller.params = { required: 1, opt: 100, unwanted: 'hello' }
        response = @controller.show
        refute response

        assert_equal({:json=>"{\"error\":\"Parameter(s) unwanted not recognised in strict mode\"}",
         :plain=>"Parameter(s) unwanted not recognised in strict mode",
         :status=>:not_acceptable}, @controller.last_render_params)
      end
    end
  end
end
