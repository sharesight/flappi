# frozen_string_literal: true

module Examples
  module Exercise11
    include Flappi::Definition

    # Strictly to test which folder this came from.  This would not be in a real definition folder.
    # see test/definition_locator_test.rb
    def self.definition_source
      'examples'
    end

    def endpoint
      group 'Test_Exercise'
      http_method 'GET'
      path '/examples/exercise11'
      title 'Exercise API 11'
      description 'Exercise definition DSL #11'

      param :include, type: BOOLEAN

      query do |params|
        if params[:include]
          { a: 5,
            instrument: {
                code: 'AAA'
            }
          }
        else
          { a: 15 }
        end
      end
    end

    def respond
      build do
        field :a, type: Integer
        object :instrument, when: SOURCE_PRESENT do
          field :code
        end
      end
    end
  end
end
