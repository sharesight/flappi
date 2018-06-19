# frozen_string_literal: true

# rubocop:disable Style/RedundantReturn, Lint/MissingCopEnableDirective

module Examples
  module NoContent
    include Flappi::Definition

    def endpoint; end

    def respond
      return # nothing; this will 204
    end
  end
end
