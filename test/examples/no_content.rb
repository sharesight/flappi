# frozen_string_literal: true

module Examples
  module NoContent
    include Flappi::Definition

    def endpoint
    end

    def respond # literally no content
    end
  end
end
