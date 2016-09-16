require 'minitest/autorun'
require 'shoulda'
require 'pp'

require 'flappi'

class TestDef
  include ::Flappi::Definition
end

class TestObject
  def self.where(params)
    self.new
  end
end

class ::Flappi::ResponseBuilderTest < MiniTest::Test

  context 'Response Builder' do
    setup do
      @response_builder = ::Flappi::ResponseBuilder.new
      @response_builder.source_definition = TestDef.new
      @response_builder.controller_params = { portfolio_id: '123', extra: '456', auth_token: 'xyzzy', controller: 'test', action: 'test' }
      @response_builder.controller_query_parameters = {}
    end

    context 'build' do
      should 'yield to block with no object options' do
        yielded = false
        built_response = @response_builder.build({}) do
          yielded = true
        end

        assert yielded
        assert_equal( {}, built_response)
      end

      should 'yield to block with object created using where' do
        yielded = false
        built_response = @response_builder.build(type: TestObject) do |obj|
          yielded = true
          assert obj.is_a?(TestObject)
        end

        assert yielded
        assert_equal( {}, built_response)
      end

      should 'yield to block with object created using query block' do
        @response_builder.query do
          { a: 1, b: 100 }
        end

        yielded = false
        built_response = @response_builder.build(type: TestObject) do |obj|
          yielded = true
          assert_equal( { a: 1, b: 100 }, obj)
        end

        assert yielded
        assert_equal( {}, built_response)
      end

      context 'object' do

        should 'put a named block into response' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |_s|
              @response_builder.field :a, 100, nil
            end

            @response_builder.object(:my_object, object_block)
          end

          assert_equal({ 'my_object' => { 'a' => 100 } }, built_response)
        end

        should 'put an inlined block into response' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |_s|
              @response_builder.field :a, 100, nil
            end

            @response_builder.object({inline_always: true}, object_block)
          end

          assert_equal({ 'a' => 100 }, built_response)
        end
      end

      context 'objects' do

        should 'put multiple blocks from passed array into response' do
          input = [{a: 11, b: 22}, {a:55, b:66}]
          built_response = @response_builder.build({}) do
            object_block = lambda do |_s|
              @response_builder.field :a, nil
              @response_builder.field :b, nil
            end

            @response_builder.objects(:my_object, input, object_block)
          end

          assert_equal({ 'my_object' =>  [{'a' => 11, 'b' => 22}, {'a' => 55, 'b' => 66}] }, built_response)
        end

      end

      context 'link' do
        should 'put self link into response' do
          @response_builder.controller_url = 'http://server/test/123/endpoint'
          @response_builder.source_definition.path '/:portfolio_id/endpoint'

          built_response = @response_builder.build({}) do
            @response_builder.link(:self)
          end

          assert_equal( {"links"=>{"self"=>"http://server/test/123/endpoint"}}, built_response)
          end
      end

      context 'field' do

        should 'put field with name and value into response' do
          built_response = @response_builder.build({}) do
            @response_builder.field :a, 100, nil
          end

          assert_equal( { 'a' => 100 }, built_response)
        end

        should 'put field with name and value from query into response' do
          @response_builder.query do
            { a: 1, b: 200 }
          end

          built_response = @response_builder.build({}) do
            @response_builder.field :b, nil
          end

          assert_equal( { 'b' => 200 }, built_response)
        end

        should 'put field with name and value from block into response' do
          @response_builder.query do
            { a: 1, b: 200 }
          end

          field_block = lambda { |_q| 555 }

          built_response = @response_builder.build({}) do
            @response_builder.field(:c, field_block)
          end

          assert_equal( { 'c' => 555 }, built_response)
        end

        should 'put field with hash of name and value into response' do
          built_response = @response_builder.build({}) do
            @response_builder.field({ name: :a, value: 100 }, nil)
          end

          assert_equal( { 'a' => 100 }, built_response)
        end
      end
    end

    context 'internals' do

      context 'controller_base_url' do
        should 'work against path with no params' do
          @response_builder.controller_url = 'http://server/test/other/endpoint'
          @response_builder.source_definition.path '/other/endpoint'

          assert_equal 'http://server/test', @response_builder.send(:controller_base_url)
        end

        should 'work against path with params inside' do
          @response_builder.controller_url = 'http://server/test/other/123/endpoint'
          @response_builder.source_definition.path '/other/:portfolio_id/endpoint'

          assert_equal 'http://server/test', @response_builder.send(:controller_base_url)
        end

        should 'work against path with param at front' do
          @response_builder.controller_url = 'http://server/test/123/endpoint'
          @response_builder.source_definition.path '/:portfolio_id/endpoint'

          assert_equal 'http://server/test', @response_builder.send(:controller_base_url)
        end
      end

      context 'expand_link_path' do
        setup do
          @response_builder.controller_url = 'http://server/test/123/endpoint'
          @response_builder.source_definition.path '/:portfolio_id/endpoint'
        end

        should 'work on own path where no query params' do
          assert_equal 'http://server/test/123/endpoint', @response_builder.send(:expand_link_path, '/:portfolio_id/endpoint')
        end

        should 'work on own path with query params' do
          @response_builder.controller_query_parameters = { a: '1', other: 'test' }
          @response_builder.controller_params.merge @response_builder.controller_query_parameters

          assert_equal 'http://server/test/123/endpoint?a=1&other=test',
                       @response_builder.send(:expand_link_path, '/:portfolio_id/endpoint', { a: '1', other: 'test' })
        end

        should 'work on referenced path where no query params' do
          assert_equal 'http://server/test/portfolios/123/ref',
                       @response_builder.send(:expand_link_path, '/portfolios/:portfolio_id/ref')
        end

      end
    end
  end
end
