# frozen_string_literal: true

module Examples
  class ExerciseModel
    attr_accessor :params, :options

    def self.where(params, options = {})
      res = ExerciseModel.new

      res.params = params
      res.options = options

      res
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
