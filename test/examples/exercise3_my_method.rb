# frozen_string_literal: true
module Examples
  module Exercise3MyMethod
    include Flappi::Definition

    def endpoint
      group 'Test_Exercise3'
      method 'POST'
      path '/examples/exercise3/my_method'
      title 'Exercise API 3'
      description 'Exercise definition DSL #3'
      param :inline, type: Integer, doc: 'Inline param'

      query do |params|
        { ok: true }
      end

      response_example(<<~END_EXAMPLE
      {
        ok: true
      }
      END_EXAMPLE
      )
    end

    def respond
      build do
        field :ok, type: BOOLEAN
      end
    end
  end
end
