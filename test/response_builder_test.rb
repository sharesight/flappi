# frozen_string_literal: true

require_relative 'test_helper'
require 'pp'

require_relative 'examples/version_plan'

class TestDef
  include ::Flappi::Definition
end

class TestObject
  def self.where(_params)
    new
  end
end

class ::Flappi::ResponseBuilderTest < Minitest::Test
  context 'Response Builder' do
    setup do
      @response_builder = ::Flappi::ResponseBuilder.new
      @response_builder.source_definition = TestDef.new
      @response_builder.controller_params = { portfolio_id: '123', extra: '456', auth_token: 'xyzzy', controller: 'test', action: 'test' }
      @response_builder.controller_query_parameters = {}
      @response_builder.version_plan = Examples::VersionPlan
      @response_builder.requested_version = Examples::VersionPlan.parse_version('v2.1')

      @test_proc = ->(_cp) { { a: 1, b: 200 } }
    end

    context 'build' do
      should 'yield to block with no object options' do
        yielded = false
        built_response = @response_builder.build({}) do
          yielded = true
        end

        assert yielded
        assert_equal({}, built_response)
      end

      should 'yield to block with object created using where' do
        yielded = false
        built_response = @response_builder.build(type: TestObject) do |obj|
          yielded = true
          assert obj.is_a?(TestObject)
        end

        assert yielded
        assert_equal({}, built_response)
      end

      should 'yield to block with object created using query block' do
        @response_builder.query(@test_proc)

        yielded = false
        built_response = @response_builder.build(type: TestObject) do |obj|
          yielded = true
          assert_equal({ a: 1, b: 200 }, obj)
        end

        assert yielded
        assert_equal({}, built_response)
      end

      context 'object' do
        should 'put a named block into response' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |_s|
              @response_builder.field :a, 100, nil
            end

            @response_builder.object({ name: :my_object, value: true}, object_block)
          end

          assert_equal({ 'my_object' => { 'a' => 100 } }, built_response)
        end

        should 'put an inlined block into response' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |_s|
              @response_builder.field :a, 100, nil
            end

            @response_builder.object({ inline_always: true }, object_block)
          end

          assert_equal({ 'a' => 100 }, built_response)
        end

        should 'do nothing when the version is unmatched' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |_s|
              @response_builder.field :a, 100, nil
            end

            @response_builder.object({ inline_always: true, version: { equals: 'v2.0' } }, object_block)
          end

          assert_equal({}, built_response)
        end

        should 'raise an error when no name or inline_always' do
          err = assert_raises RuntimeError do
            @response_builder.build({}) do
              object_block = lambda do |_s|
                @response_builder.field :a, 100, nil
              end

              @response_builder.object({}, object_block)
            end
          end

          assert_equal 'object requires either a name or inline_always: true', err.to_s
        end
      end

      context 'objects' do
        should 'put multiple blocks from passed array into response' do
          input = [{ a: 11, b: 22 }, { a: 55, b: 66 }]
          built_response = @response_builder.build({}) do
            object_block = lambda do |_s|
              @response_builder.field :a, nil
              @response_builder.field :b, nil
            end

            @response_builder.objects(:my_object, input, object_block)
          end

          assert_equal({ 'my_object' => [{ 'a' => 11, 'b' => 22 }, { 'a' => 55, 'b' => 66 }] }, built_response)
        end

        should 'call block with no parameter for nil array values' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |*value_or_nil|
              @response_builder.field(:a, value_or_nil.empty? ? 'empty' : value_or_nil.first, nil)
            end

            @response_builder.objects(:my_object, [1, nil, 3], object_block)
          end

          assert_equal({ 'my_object' => [{ 'a' => 1 }, { 'a' => 'empty' }, { 'a' => 3 }] }, built_response)
        end

        should 'call block with multiple parameters for array values' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |number, name|
              @response_builder.field(:number, number, nil)
              @response_builder.field(:name, name, nil)
            end

            @response_builder.objects(:my_object, [[1, :one], [2, :two]], object_block)
          end

          assert_equal({ 'my_object' => [{ 'number' => 1, 'name' => :one }, { 'number' => 2, 'name' => :two }] }, built_response)
        end

        should 'produce a hash with specified key' do
          built_response = @response_builder.build({}) do
            object_block = lambda do |number|
              @response_builder.hash_key("key_#{number}", nil)
              @response_builder.field(:n, number, nil)
            end

            @response_builder.objects(:my_object, [1, 2], { hashed: true }, object_block)
          end

          assert_equal({ 'my_object' => { 'key_1' => { 'n' => 1 }, 'key_2' => { 'n' => 2 } } }, built_response)
        end
      end

      context 'link' do
        should 'put self link into response' do
          @response_builder.controller_url = 'http://server/test/123/endpoint'
          @response_builder.source_definition.path '/:portfolio_id/endpoint'

          built_response = @response_builder.build({}) do
            @response_builder.link(:self)
          end

          assert_equal({ 'links' => { 'self' => 'http://server/test/123/endpoint' } }, built_response)
        end

        should 'put defined link into response' do
          @response_builder.controller_url = 'http://server/test/123/endpoint'
          @response_builder.source_definition.path '/:portfolio_id/endpoint'

          built_response = @response_builder.build({}) do
            @response_builder.link(:self)
            @response_builder.link(key: :other, path: '/other_endpoint?extra=:extra')
          end

          assert_equal({ 'links' => { 'self' => 'http://server/test/123/endpoint',
                                      'other' => 'http://server/test/other_endpoint?extra=456' } },
                       built_response)
        end

        context "encoded links" do
          setup do
            # Flappi requires a mess of boilerplate to test and may conflict with the parent `setup`, so we roll our own
            @encoded_response_builder = ::Flappi::ResponseBuilder.new
            @encoded_response_builder.source_definition = TestDef.new
            @encoded_response_builder.controller_params = { auth_token: 'xyzzy', controller: 'test', action: 'test' }
            @encoded_response_builder.controller_query_parameters = {}
            @encoded_response_builder.version_plan = Examples::VersionPlan
            @encoded_response_builder.requested_version = Examples::VersionPlan.parse_version('v2.1')
          end

          should 'work with spaces and basic symbols' do
            @encoded_response_builder.controller_url = 'http://server/test/endpoint/foo bar!@#$%^&*()_+{}:"<>?/,.;[]-='
            @encoded_response_builder.controller_params[:name] = 'foo bar!@#$%^&*()_+{}:"<>?/,.;[]-='
            @encoded_response_builder.source_definition.path '/endpoint/:name'

            built_response = @encoded_response_builder.build({}) do
              @encoded_response_builder.link(:self)
            end

            assert_equal({ 'links' => { 'self' => 'http://server/test/endpoint/foo+bar%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%3A%22%3C%3E%3F%2F%2C.%3B%5B%5D-%3D' } },
                         built_response)
          end

          should 'properly encode a plus as %2B rather than a space via params' do
            @encoded_response_builder.controller_url = 'http://server/test/endpoint/foo+bar' # this is `foo bar` to a browser
            @encoded_response_builder.controller_params[:name] = 'foo bar'
            @encoded_response_builder.controller_params[:other] = '1+2'
            @encoded_response_builder.source_definition.path '/endpoint/:name'

            built_response = @encoded_response_builder.build({}) do
              @encoded_response_builder.link(:self)
              @encoded_response_builder.link(key: :other, path: '/other_endpoint?other=:other')
            end

            assert_equal({ 'links' => { 'self' => 'http://server/test/endpoint/foo+bar',
                                        'other' => 'http://server/test/other_endpoint?other=1%2B2' } },
                         built_response)
          end
        end
      end

      context 'field' do
        should 'put field with name and value into response' do
          built_response = @response_builder.build({}) do
            @response_builder.field :a, 100, nil
          end

          assert_equal({ 'a' => 100 }, built_response)
        end

        should 'put field with name and value from query into response' do
          @response_builder.query @test_proc

          built_response = @response_builder.build({}) do
            @response_builder.field :b, nil
          end

          assert_equal({ 'b' => 200 }, built_response)
        end

        should 'put field with name and value from block into response' do
          @response_builder.query @test_proc

          field_block = ->(_q) { 555 }

          built_response = @response_builder.build({}) do
            @response_builder.field(:c, field_block)
          end

          assert_equal({ 'c' => 555 }, built_response)
        end

        should 'put field with hash of name and value into response' do
          built_response = @response_builder.build({}) do
            @response_builder.field({ name: :a, value: 100 }, nil)
          end

          assert_equal({ 'a' => 100 }, built_response)
        end
      end

      context 'reference' do
        should 'put an untyped reference into response' do
          built_response = @response_builder.build({}) do
            block = lambda do
              @response_builder.field(:id, 999, nil)
              @response_builder.field(:fv, 100, nil)
            end

            @response_builder.reference(:myref, block)
          end

          assert_equal({ 'myref_id' => 999, 'myref' => [{ 'id' => 999, 'fv' => 100 }] }, built_response)
        end

        should 'put an typed polymorphic reference into response' do
          built_response = @response_builder.build({}) do
            block = lambda do
              @response_builder.field(:id, 999, nil)
              @response_builder.field(:fv, 100, nil)
            end

            @response_builder.reference({ name: :myref, type: 'Thingy', for: 'thingy', generate_from_type: true }, block)
          end

          assert_equal({ 'myref_id' => 999, 'myref_type' => 'Thingy', 'thingies' => [{ 'id' => 999, 'fv' => 100 }] }, built_response)
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

      should 'cast_value' do
        assert_nil @response_builder.cast_value(nil, Flappi::Definition::BOOLEAN, nil)
        assert_equal false, @response_builder.cast_value(false, Flappi::Definition::BOOLEAN, nil)
        assert_equal true, @response_builder.cast_value(1, Flappi::Definition::BOOLEAN, nil)

        assert_equal 1.234, @response_builder.cast_value('1.234', BigDecimal, nil)
        assert_equal 1.235, @response_builder.cast_value('1.2345678', Float, 3)

        assert_equal 567, @response_builder.cast_value('567', Integer, nil)

        assert_equal({ value: 10 }, @response_builder.cast_value({ value: 10 }, Hash, nil))
      end

      should 'access_member_somehow' do
        assert_equal 1, @response_builder.access_member_somehow({ a: 1 }, 'a')
        assert_equal 1, @response_builder.access_member_somehow({ a: 1 }, :a)

        assert_equal 2, @response_builder.access_member_somehow({ 'b' => 2 }, 'b')
        assert_equal 2, @response_builder.access_member_somehow({ 'b' => 2 }, :b)

        refute @response_builder.access_member_somehow({ 'b' => 2 }, :c)

        assert_equal 3, @response_builder.access_member_somehow(OpenStruct.new(c: 3), 'c')
        assert_equal 3, @response_builder.access_member_somehow(OpenStruct.new(c: 3), :c)
      end

      context 'expand_link_path' do
        setup do
          @response_builder.controller_url = 'http://server/test/123/endpoint'
          @response_builder.source_definition.path '/:portfolio_id/endpoint'
          @response_builder.controller_query_parameters = {}
        end

        should 'work on own path where no query params' do
          assert_equal 'http://server/test/123/endpoint', @response_builder.send(:expand_self_path, '/:portfolio_id/endpoint', [])
        end

        should 'work on own path with query params' do
          @response_builder.controller_query_parameters = { a: '1', other: 'test' }
          @response_builder.controller_params.merge! @response_builder.controller_query_parameters

          assert_equal 'http://server/test/123/endpoint?a=1&other=test',
                       @response_builder.send(:expand_self_path, '/:portfolio_id/endpoint', %i[a other])
        end

        should 'work on path with replaceable query params' do
          @response_builder.controller_query_parameters = { a: '1', other: 'test', b: 100, c: 'Not Me' }
          @response_builder.controller_params.merge @response_builder.controller_query_parameters

          assert_equal 'http://server/test/123/endpoint?b=88',
                       @response_builder.send(:expand_link_path, '/:portfolio_id/endpoint?b=88', {})
        end

        should 'work on referenced path where no query params' do
          assert_equal 'http://server/test/portfolios/123/ref',
                       @response_builder.send(:expand_link_path, '/portfolios/:portfolio_id/ref', {})
        end

        should 'work with a substitutable query param as Rails 4' do
          @response_builder.controller_params = { 'consolidated' => false, 'portfolio_id' => 123 }
          @response_builder.controller_query_parameters = { consolidated: false }

          assert_equal 'http://server/test/portfolios/123?consolidated=false',
                       @response_builder.send(:expand_link_path, '/portfolios/:portfolio_id?consolidated=:consolidated', {})
        end

        should 'work with a substitutable query param as Rails 5 (params = symbol hash)' do
          @response_builder.controller_params = { consolidated: false, portfolio_id: 123 }
          @response_builder.controller_query_parameters = { consolidated: false }

          assert_equal 'http://server/test/portfolios/123?consolidated=false',
                       @response_builder.send(:expand_link_path, '/portfolios/:portfolio_id?consolidated=:consolidated', {})
        end

        should 'substitute from data context into links' do
          @response_builder.controller_params = { consolidated: false }
          @response_builder.controller_query_parameters = { consolidated: false }

          assert_equal 'http://server/test/portfolios/123?consolidated=false',
                       @response_builder.send(:expand_link_path, '/portfolios/:portfolio_id?consolidated=:consolidated',
                          portfolio_id: 123)
        end
      end

      context 'version_included' do
        should 'return true when no version specified args' do
          assert @response_builder.send(:version_wanted, name: 'test', value: 100)
        end

        should 'return true when a requested version specified' do
          assert @response_builder.send(:version_wanted, name: 'test', value: 100, version: { equals: 'v2.1' })
        end

        should 'return false when a non-requested version specified' do
          refute @response_builder.send(:version_wanted, name: 'test', value: 100, version: { equals: 'v2.0' })
        end
      end
    end
  end
end
