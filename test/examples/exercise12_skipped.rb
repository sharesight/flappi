# frozen_string_literal: true

module Examples
  module Exercise12Skipped
    include Flappi::Definition

    def skip_docs
      true
    end

    def endpoint
      group 'Test_Exercise'
      http_method 'GET'
      path '/examples/exercise12'
      title 'Exercise API 12'
      description 'Exercise definition DSL #12 with versioning'
      version equals: 'v2.*-mobile'

      param :required, optional: false, type: Float do |v|
        v >= 0 && v < 10 ? nil : 'Parameter v outside range 0..10'
      end
    end

    def respond
      build type: Examples::ExerciseModel, options: { test: 'hello' } do
        field :all

        field :v2_0_only, version: { equals: 'v2.0.*-*' }
        field :v2_1_only, version: { equals: 'v2.1.*-*' }

        field :params
        field :options
      end
    end
  end
end
