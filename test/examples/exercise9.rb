# frozen_string_literal: true

module Examples
  module Exercise9
    include Flappi::Definition

    # Strictly to test which folder this came from.  This would not be in a real definition folder.
    # see test/definition_locator_test.rb
    def self.definition_source
      'examples'
    end

    def endpoint
      group 'Test_Exercise'
      http_method 'GET'
      path '/examples/exercise1'
      title 'Exercise API 9'
      description 'Exercise definition DSL #9'
      param(:extra, type: Integer, doc: 'An extra query parameter', optional: true).processor do |value|
        value || 1234
      end

      param :defaulted, type: Integer, doc: 'Parameter with default', default: 123
      param :hidden_param, type: Integer, hidden: true, optional: true

      query do |params|
        if params[:return_error]
          return_error 422, 'Eek!'
        elsif params[:return_error_hash]
          return_error(422, e: 'Fail', reason: 'wanted')
        else
          [{ n: 1, name: 'one' },
           { n: 2, name: 'two' }]
        end
      end

      link :other, 'other/:defaulted/other_api?extra=:extra'
      link :self

      request_example('"/api/examples/exercise?extra=100"')
      request_example({ label: 'Another Request Example' }, '"/api/examples/exercise?extra=100"')
      request_example({ label: 'Special Request Example' }, '"/api/examples/exercise?extra=100"')

      example_text = <<~END_EXAMPLE
        {
          extra_plus_1: 101,
          rows: [
            { n: 1, name: 'one', alt_name: 'one' },
            { n: 2, name: 'two', alt_name: 'one' }
          ]
        }
      END_EXAMPLE
      response_example(example_text)
      response_example({ label: 'Another Response Example' }, example_text)
      response_example({ label: 'Special Response Example' }, example_text)

      api_error '404 Not Found', 'error_code', 'Internal ID to identify the root cause'
      api_error '404 Not Found', 'error', 'Error details'
    end

    def respond
      build do
        field :extra, (params[:extra] || 0) + 100
        field :defaulted, params[:defaulted]

        objects name: :data do |row|
          field :n, row[:n]
          field :name, row[:name]
          field :alt_name, source: :name
        end
      end
    end
  end
end
