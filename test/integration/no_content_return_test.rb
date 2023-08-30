# frozen_string_literal: true

require 'pp'
require_relative '../test_helper'
require_relative '../examples/no_content_return'

module Examples
  class NoContentReturnController < ExampleController
  end
end

module Integration
  class NoContentReturnTest < Minitest::Test
    context 'Response to NoContentReturn' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'respond :no_content the stubbed controller head method when content is falsey' do
        controller = Examples::NoContentReturnController.new
        controller.show # doesn't return anything useful; not an actual response

        assert_equal(:no_content, controller.last_head_params)
      end
    end
  end
end
