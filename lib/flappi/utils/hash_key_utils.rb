# frozen_string_literal: true

module Flappi
  module Utils
    module HashKeyUtils
      # dig, using symbol or string keys
      def self.dig_indifferent(hash_string_symbol, *items)
        # Flappi::Utils::Logger.d "dig #{hash_string_symbol}, #{items}"
        return nil unless hash_string_symbol
        return hash_string_symbol if items.empty?
        return nil unless hash_string_symbol.respond_to?(:dig)

        located = hash_string_symbol[items.first.to_s] || hash_string_symbol[items.first.to_s.to_sym]
        return located if items.length == 1

        return nil unless located.is_a?(Hash)

        dig_indifferent(located, *items[1..])
      end

      # bury under last entry using symbol or string keys
      # doesn't do a deep bury (no hash)
      def self.bury_indifferent(hash_string_symbol, value, *items)
        return unless hash_string_symbol && !items.empty?

        parent = dig_indifferent(hash_string_symbol, *items[0...-1])
        return unless parent.respond_to?(:dig)

        if parent[items.last.to_s]
          parent[items.last.to_s] = value
        elsif parent[items.last.to_s.to_sym]
          # symbol bury under symbol
          parent[items.last.to_s.to_sym] = value
        else
          # bury as path
          parent[items.last] = value
        end
      end
    end
  end
end
