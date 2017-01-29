# frozen_string_literal: true
require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise1'

module Examples
  class Exercise1Controller
    attr_accessor :params
    attr_accessor :last_render_params

    def initialize
      self.params = { extra: 50 }
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
  class Exercise1ResponseTest < MiniTest::Test
    context 'Response to Exercise1' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'respond with a composed block' do
        response = Examples::Exercise1Controller.new.show

        assert_equal({ 'extra' => 150, 'defaulted' => 123, 'data' => [{ 'n' => 1, 'name' => 'one' }, { 'n' => 2, 'name' => 'two' }] },
                       response)
      end

      should 'respond with a composed block when no param' do
        controller = Examples::Exercise1Controller.new
        controller.params = {}
        response = controller.show

        assert_equal({ 'extra' => 100, 'defaulted' => 123, 'data' => [{ 'n' => 1, 'name' => 'one' }, { 'n' => 2, 'name' => 'two' }] },
                     response)
      end

      should 'override a default param from query' do
        controller = Examples::Exercise1Controller.new
        controller.params = { defaulted: 888 }
        response = controller.show

        assert_equal({ 'extra' => 100, 'defaulted' => 888, 'data' => [{ 'n' => 1, 'name' => 'one' }, { 'n' => 2, 'name' => 'two' }] },
                     response)
      end

      should 'detect validation failures' do
        controller = Examples::Exercise1Controller.new
        controller.params = { extra: 'Hello!' }
        response = controller.show
        refute response

        assert_equal({ json: '{"error":"Parameter extra must be of type Integer"}',
                       text: 'Parameter extra must be of type Integer',
                       status: :not_acceptable }, controller.last_render_params)
      end

      should 'return an error when provoked' do
        controller = Examples::Exercise1Controller.new
        controller.params = { return_error: true }
        response = controller.show

        assert_equal('Eek!', response.status_message)
        assert_equal(422, response.status_code)
      end
    end
  end
end
