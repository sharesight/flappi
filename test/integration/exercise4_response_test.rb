# frozen_string_literal: true

require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise4'

module Examples
  class Exercise4Controller < ExampleController
  end
end

module Integration
  class Exercise4ResponseTest < Minitest::Test
    context 'Response to Exercise4' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'respond with a composed block' do
        response = Examples::Exercise4Controller.new.show

        assert_equal({ 'a_not' => 100, 'b_how' => 100 }, response)
      end
    end
  end
end
