# frozen_string_literal: true

module Examples
  module NoContentReturn
    include Flappi::Definition

    def endpoint
      query do
        return_no_content
      end
    end

    def respond
      build do
      end
    end
  end
end
