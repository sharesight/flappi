require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise1'

class JsonFormatter
  def json
    yield
  end
end

module Examples
  class Exercise1Controller
    attr_accessor :params
    attr_accessor :last_render_params

    def initialize
      self.params = {extra: 50}
    end

    def show
      Flappi.build_and_respond(self)
    end

    def request
      return OpenStruct.new(query_parameters: params)
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
      should 'respond with a composed block' do
        response = Examples::Exercise1Controller.new.show

        assert_equal( {json: {"extra"=>150, "data"=>[{"n"=>1, "name"=>"one"}, {"n"=>2, "name"=>"two"}]},
            :status=>:ok},
            response)
      end

      should 'respond with a composed block when no param' do
        controller = Examples::Exercise1Controller.new
        controller.params = {}
        response = controller.show

        assert_equal( {json: {"extra"=>100, "data"=>[{"n"=>1, "name"=>"one"}, {"n"=>2, "name"=>"two"}]},
                       :status=>:ok},
                      response)
      end

      should 'detect validation failures' do
        controller = Examples::Exercise1Controller.new
        controller.params = {extra: 'Hello!'}
        response = controller.show
        refute response

        assert_equal( {:json=>"{\"errors\":\"Parameter extra must be of type Integer\"}",
                       :text=>"Parameter extra must be of type Integer",
                       :status=>:not_acceptable}, controller.last_render_params )
      end
    end
  end
end
