# frozen_string_literal: true

require_relative '../test_helper'

require_relative '../examples/exercise11_object_nest'

module Examples
  class Exercise11Controller < ExampleController
    def initialize
      self.params = { }
    end

    def request
      OpenStruct.new(query_parameters: params, url: 'http://test.api/exercise11')
    end
  end
end

module Integration
  class Exercise11ResponseTest < Minitest::Test
    context 'Response to Exercise11' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end

        @controller = Examples::Exercise11Controller.new
      end

      should 'respond with instrument code when include true' do
        @controller.params = { include: true }
        response = @controller.show

        assert_equal({ 'a' => 5, 'instrument' => { 'code' => 'AAA' } }, response)
      end

      should 'respond with nil instrument when include false' do
        @controller.params = { include: false }
        response = @controller.show

        assert_equal({ 'a' => 15 }, response)
      end
    end
  end
end
