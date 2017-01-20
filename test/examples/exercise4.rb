# frozen_string_literal: true
module Examples
  module Exercise3
    include Flappi::Definition

    def endpoint
      group 'Test_Exercise'
      method 'GET'
      path '/examples/exercise1'
      title 'Exercise API 3'
      description 'Exercise definition DSL #3'

      request_example('/api/examples/exercise3')
      response_example(<<~END_EXAMPLE
      {
      }
      END_EXAMPLE
      )
    end

    def respond
      build do
        my_field(:a, false)
        my_field(:b, true)
      end
    end

    def my_field(name, how)
      field "#{name}_not", 100, doc: 'First field (not)', when: !how
      field "#{name}_how", 100, doc: 'Second field (how)', when: how
    end

  end
end
