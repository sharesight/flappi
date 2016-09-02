require 'minitest/autorun'
require 'shoulda'

require 'flappi'

class TestDef
  include ::Flappi::Definition

end

class ::Flappi::ResponseBuilderTest < MiniTest::Test

  context 'internals' do

    setup do
      @response_builder = ::Flappi::ResponseBuilder.new
      @response_builder.source_definition = TestDef.new
      @response_builder.controller_params = { portfolio_id: '123', extra: '456', auth_token: 'xyzzy', controller: 'test', action: 'test' }
      @response_builder.controller_query_parameters = {}
    end

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
