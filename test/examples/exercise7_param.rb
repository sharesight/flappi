# frozen_string_literal: true

module Examples
  module Exercise7Param
    include Flappi::Definition

    # Strictly to test which folder this came from.  This would not be in a real definition folder.
    # see test/definition_locator_test.rb
    def self.definition_source
      'examples'
    end

    def endpoint
      group 'Test_Exercise'
      http_method 'PATCH'
      path '/examples/exercise7'
      title 'Exercise API 7'
      description 'Exercise definition DSL #7 - parameters including nested'

      param :id, type: Integer, doc: 'Id to update'
      param 'obj/nested', doc: 'A nested parameter'

      query(&:itself)

      link :self

      request_example('"/api/examples/exercise7')
      response_example <<~END_EXAMPLE
        {
          obj: {
            nested: 'blah'
          }
        }
      END_EXAMPLE
    end

    def respond
      build do
        object name: :obj do
          field :nested
        end
      end
    end
  end
end
