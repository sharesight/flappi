# frozen_string_literal: true

module Examples
  module EmptyObject
    include Flappi::Definition

    def endpoint
    end

    def respond
      build do
        # this will return an empty object, not :no_content
      end
    end
  end
end
