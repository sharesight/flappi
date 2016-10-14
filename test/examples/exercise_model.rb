module Examples
  class ExerciseModel

    def self.where(params)
      ExerciseModel::new
    end

    def all
      'all_versions'
    end

    def v2_0_only
      2.0
    end

    def v2_1_only
      2.1
    end

  end
end
