# frozen_string_literal: true
module Flappi
  module Utils
    module ArgUtils
      # @example Given some args of a form such as:
      #   a: 1 (hash options)
      #   :a, 1 (splat)
      #    a: 1, b: 2 (hash options)
      #    :a, 1, :b, 2 (splat)
      #    :a, 1, :b, 2, :c, 3 (splat)
      #    :a, 1, :b, 2, :a, 3 (splat with repeat)
      #    {a: 1, b: 2}, {a: 3} (two hashes)
      #
      #    return an array of name/value pairs (as arrays)
      #    this effectively gives us a multihash where keys can be duplicated
      def self.paired_args(*a)
        # an array of either key, value or hashes
        a.map do |it|
          if it.is_a? Hash
            it.to_a
          else
            it
          end
        end.flatten.each_slice(2).to_a
      end
    end
  end
end
