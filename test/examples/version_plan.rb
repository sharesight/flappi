# frozen_string_literal: true

module Examples
  class VersionPlan
    extend Flappi::VersionPlan

    # Version numbers are of the form [text][N][,]+[-flavour]

    version 'v2.0.0' do
      flavour :mobile
    end

    version 'v2.1.0' do
      flavour :ember
      flavour :flat
      flavour :mobile
    end

    version 'v3.0.0'

    flavour ''
  end
end
