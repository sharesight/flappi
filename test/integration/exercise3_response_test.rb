# frozen_string_literal: true
require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise3'

module Examples
  class Exercise3Controller
    attr_accessor :params
    attr_accessor :last_render_params

    def initialize
      self.params = {}
    end

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
  class Exercise3ResponseTest < MiniTest::Test
    context 'Response to Exercise3' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'respond with a composed block' do
        response = Examples::Exercise3Controller.new.show

        assert_equal({ json: { "a_not"=>100, "b_how"=>100 },
                       status: :ok },
                     response)
      end
    end
  end
end
