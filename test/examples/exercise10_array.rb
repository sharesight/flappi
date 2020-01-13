# frozen_string_literal: true

module Examples
  module Exercise10Array
    include Flappi::Definition

    def endpoint
      group 'Test_Exercise'
      http_method 'GET'
      path '/examples/exercise10'
      title 'Exercise API 10 (Arrays)'
      description 'Exercise definition DSL #10'
      param :arr, type: Array, doc: 'Array parameter', optional: false

      query do |params|
        params # loopback
      end
    end

    def respond
      build do
        field :arr, type: Array
      end
    end
  end
end
