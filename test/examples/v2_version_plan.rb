# frozen_string_literal: true
module Examples
  class V2VersionPlan
    extend Flappi::VersionPlan

    # Version numbers are of the form [text][N][,]+[-flavour]

    version 'V2.0.0'

    version 'V2.1.0' do
      flavour :ember
      flavour :flat
    end

    flavour ''

    # 2.0.0 or 2.1.0 can take the mobile flavour, which is for internal use only
    flavour :mobile
  end
end
