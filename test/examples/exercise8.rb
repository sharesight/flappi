# frozen_string_literal: true

module Examples
  module Exercise8
    include Flappi::Definition

    def endpoint
      group 'Test_Exercise'
      http_method 'GET'
      path '/examples/exercise8'
      title 'Exercise API 8'
      description 'Exercise #{definition DSL #1}8 - test strict mode'
      param(:required, type: Integer, doc: 'Required parameter', optional: false)
      param(:opt, type: Integer, doc: 'Optional parameter', optional: true)
      param('nested/nest_opt', type: Integer, doc: 'Nested optional parameter', optional: true)
      strict true

      request_example('"/api/examples/exercise8?required=100"')
      response_example <<~END_EXAMPLE
        {
          { a: 'ok' }
        }
      END_EXAMPLE
    end

    def respond
      build do
        field :a, value: 'ok'
      end
    end
  end
end
