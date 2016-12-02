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
      # post_param :post_data, doc: 'data to be posted'
      param :inline, type: Integer, doc: 'Inline param'

      query do |params|
        { ok: true, post_data: params[:post_data] }
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
        field :post_data
      end
    end
  end
end
