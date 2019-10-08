# frozen_string_literal: true

require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise6'

module Examples
  class Exercise6Controller < ExampleController
    def request
      OpenStruct.new(query_parameters: {}, url: 'http://test.api/exercise6')
    end
  end
end

module Integration
  class Exercise6ResponseTest < MiniTest::Test
    context 'Response to Exercise6 with renaming' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end

        @controller = Examples::Exercise6Controller.new
      end

      should 'respond with a composed block' do
        response = @controller.show

        assert_equal({ "single" => { "n" => 1, "name" => "one" },
                       "multi" => [{ "n" => 1, "name" => "one" }, { "n" => 2, "name" => "two" }],
                       "links" => {"object_link"=>"http://test.api/exercise6/object_access"} },
          response)
      end
    end
  end
end
