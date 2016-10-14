module Examples
  module Exercise2Versioned

    include Flappi::Definition

    def endpoint
      group 'Test_Exercise'
      method 'GET'
      path '/examples/exercise2'
      title 'Exercise API 2'
      description 'Exercise definition DSL #2 with versioning'
      version equals: 'V2.*-mobile'
    end

    def respond
      build type: Examples::ExerciseModel do
        field :all

        field :v2_0_only, version: { equals: 'V2.0.*-*' }
        field :v2_1_only, version: { equals: 'V2.1.*-*' }
      end
    end
  end
end

