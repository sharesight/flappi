# frozen_string_literal: true

module Examples2
  module Exercise1
    include Flappi::Definition

    # Strictly to test which folder this came from.  This would not be in a real definition folder.
    # see test/definition_locator_test.rb
    def self.definition_source
      'examples2'
    end
  end
end
