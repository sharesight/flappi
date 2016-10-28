# frozen_string_literal: true
module Examples
  module Exercise1
    include Flappi::Definition

    def endpoint
      group 'Test_Exercise'
      method 'GET'
      path '/examples/exercise1'
      title 'Exercise API 1'
      description 'Exercise definition DSL #1'
      param :extra, type: Integer, doc: 'An extra query parameter', optional: true
      param :defaulted, type: Integer, doc: 'Parameter with default', default: 123

      query do |_params|
        [{ n: 1, name: 'one' },
         { n: 2, name: 'two' }]
      end

      request_example('/api/examples/exercise?extra=100')
      response_example(<<~END_EXAMPLE
      {
        extra_plus_1: 101,
        rows: [
          { n: 1, name: 'one' },
          { n: 2, name: 'two' }
        ]
      }
      END_EXAMPLE
                      )
    end

    def respond
      build do
        field :extra, (params[:extra] || 0) + 100
        field :defaulted, params[:defaulted]

        objects name: :data do |row|
          field :n, row[:n]
          field :name, row[:name]
        end
      end
    end
  end
end
