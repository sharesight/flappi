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
      OpenStruct.new(query_parameters: params, url: 'http://test.api/exercise1')
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

        @controller = Examples::Exercise1Controller.new
      end

      should 'respond with a composed block' do
        response = @controller.show

        assert_equal({ 'extra' => 150,
                       'defaulted' => 123,
                       'data' => [{ 'n' => 1, 'name' => 'one' }, { 'n' => 2, 'name' => 'two' }],
                       'links' => { 'other' => 'http://test.api/exercise1/other/123/other_api?extra=50',
                                    'self' => 'http://test.api/exercise1/examples/exercise1?defaulted=123&extra=50' } },
                     response)
      end

      should 'respond with a composed block when no param' do
        @controller.params = {}
        response = @controller.show

        assert_equal({ 'extra' => 1334, 'defaulted' => 123,
                       'data' => [{ 'n' => 1, 'name' => 'one' },
                                  { 'n' => 2, 'name' => 'two' }],
                       'links' => { 'other' => 'http://test.api/exercise1/other/123/other_api?extra=1234',
                                    'self' => 'http://test.api/exercise1/examples/exercise1?defaulted=123&extra=1234' } },
                     response)
      end

      should 'override a default param from query' do
        @controller.params = { defaulted: 888 }
        response = @controller.show

        assert_equal({ 'extra' => 1234 + 100, 'defaulted' => 888, 'data' => [{ 'n' => 1, 'name' => 'one' }, { 'n' => 2, 'name' => 'two' }],
                       'links' => { 'other' => 'http://test.api/exercise1/other/888/other_api?extra=1234',
                                    'self' => 'http://test.api/exercise1/examples/exercise1?defaulted=888&extra=1234' } },
                     response)
      end

      should 'detect validation failures' do
        @controller.params = { extra: 'Hello!' }
        response = @controller.show
        refute response

        assert_equal({ json: '{"error":"Parameter extra must be of type Integer"}',
                       plain: 'Parameter extra must be of type Integer',
                       status: :not_acceptable }, @controller.last_render_params)
      end

      should 'return an error when provoked' do
        @controller.params = { return_error: true }
        response = @controller.show

        assert_equal('Eek!', response.status_message)
        assert_equal(422, response.status_code)
      end
    end
  end
end
