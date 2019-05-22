# frozen_string_literal: true

require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise7_param'

module Examples
  class Exercise7ParamController < ExampleController
    def initialize
      self.params = { obj: { nested: 'hello' } }
    end

    def request
      OpenStruct.new(query_parameters: params, url: 'http://test.api/exercise7')
    end

    def update
      Flappi.build_and_respond(self)
    end
  end
end

module Integration
  class Exercise7ResponseTest < MiniTest::Test
    context 'Response to Exercise7' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end

        @controller = Examples::Exercise7ParamController.new
      end

      should 'respond with update parameters' do
        response = @controller.update

        assert_equal({ 'obj' => { 'nested' => 'hello' },
                       "links" => { "self" => "http://test.api/exercise7/examples/exercise7" } }, response)
      end
    end
  end
end
