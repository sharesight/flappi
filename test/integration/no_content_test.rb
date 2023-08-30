# frozen_string_literal: true

require 'pp'
require_relative '../test_helper'
require_relative '../examples/no_content'

module Examples
  class NoContentController < ExampleController
  end
end

module Integration
  class NoContentTest < Minitest::Test
    context 'Response to NoContent' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'respond :no_content the stubbed controller head method when content is falsey' do
        controller = Examples::NoContentController.new
        controller.show # doesn't return anything useful; not an actual response

        assert_equal(:no_content, controller.last_head_params)
      end
    end
  end
end
