# frozen_string_literal: true

module Examples
  module Exercise6
    include Flappi::Definition

    # Strictly to test which folder this came from.  This would not be in a real definition folder.
    # see test/definition_locator_test.rb
    def self.definition_source
      'examples'
    end

    def endpoint
      group 'Test_Exercise'
      http_method 'GET'
      path '/examples/exercise6'
      title 'Exercise API 6'
      description 'Exercise definition DSL #6'

      query do
        {
          single_block: { n: 1, name: 'one' },
          multi_block:
            [{ n: 1, name: 'one' },
             { n: 2, name: 'two' }]
        }
      end
    end

    def respond
      build do
        object name: :single, source: :single_block do
          field :n
          field :name
        end

        objects name: :multi, source: :multi_block do
          field :n
          field :name
        end
      end
    end
  end
end
