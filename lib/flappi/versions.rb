
# frozen_string_literal: true

module Flappi
  class Versions
    attr_reader :versions_array

    delegate :to_json, to: :string_versions
    delegate :size, :first, :last, :select, to: :versions_array

    def initialize(versions_array)
      #        puts "Versions: #{versions_array}"
      @versions_array = versions_array
    end

    def include?(version)
      #        puts "include? #{@versions_array} #{version}"
      @versions_array.any? { |tv| tv == version }
    end

    def to_s
      "[#{string_versions.join(', ')}]"
    end

    def ==(other)
      versions_array == other.versions_array
    end

    private

    def string_versions
      @versions_array.map(&:to_s)
    end
  end
end
