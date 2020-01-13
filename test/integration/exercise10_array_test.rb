# frozen_string_literal: true

require_relative '../test_helper'

require_relative '../examples/exercise10_array'

module Examples
  class Exercise10ArrayController < ExampleController
  end
end

module Integration
  class Exercise10ArrayResponseTest < MiniTest::Test
    context 'Exercise10' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end

        @controller = Examples::Exercise10ArrayController.new
      end

      should 'support array with [] args' do
        params = { 'arr' => [2, 4, 6] }
        @controller.params = params # arrayised by @controller
        response = @controller.show
        assert_equal params, response
      end

      should 'support array with comma separated args' do
        @controller.params = {'arr' => '2,4,6' }
        response = @controller.show
        assert_equal( { 'arr' => [2, 4, 6] }, response)
      end

      should 'pass literal commas in bracketed array' do
        params = { 'arr' => ['a', 'b,c', 'd'] }
        @controller.params = params # arrayised by @controller
        response = @controller.show
        assert_equal params, response
      end
    end
  end
end
