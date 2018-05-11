
# frozen_string_literal: true

module Flappi
  class Version
    attr_reader :version_array
    attr_reader :flavour

    def initialize(version_array, flavour, version_plan)
      @version_plan = version_plan
      @version_array = version_array
      @flavour = flavour.blank? ? :_blank : flavour.to_sym
    end

    def normalise
      if @version_plan.version_sig_size == version_array.size
        self
      else
        Flappi::Version.new(@version_array.fill(0, version_array.size, @version_plan.version_sig_size - version_array.size),
                            @flavour,
                            @version_plan)
      end
    end

    def to_s
      r = version_array.join('.')
      r << '-' + @flavour.to_s unless @flavour == :_blank
      r
    end

    def ==(other)
      # puts "version #{self} == #{other} ?"
      return false if other.nil?
      return false unless other.is_a? Flappi::Version

      max_slots = [@version_array.size, other.version_array.size].max

      (0...max_slots).each do |i|
        lhs = @version_array[i]
        rhs = other.version_array[i]

        return false unless compare_numeric(lhs, rhs)
      end

      compare_string(@flavour, other.flavour)
    end

    private

    def compare_numeric(a, b)
      return true if a == '*' || b == '*' # wildcard match

      (a&.to_i || 0) == (b&.to_i || 0)
    end

    def compare_string(a, b)
      return true if a == :* || b == :* # wildcard match

      a == b # no default, nil only matches nil
    end
  end
end
