module Flappi
  module Utils
    module ArgUtils

      # Given some args of a form such as:
      #  a: 1
      #  a:1, b:2
      #  :a, 1, :b, 2, :c, 3
      # {a: 1, b: 2}, {a: 3}
      # return an array of name/value pairs (as arrays)
      # this effectively gives us a multihash where keys can be duplicated
      def self.paired_args(*a)
        r = if a.is_a? Hash
          # a hash with unduplicated keys
          a.to_a
        elsif a.is_a? Array
          # an array of either key, value or hashes
          a.map do |it|
            if it.is_a? Hash
              it.to_a
            else
              it
            end
          end.flatten
        else
          raise "Expecting paired arguments of some kind at #{a}"
        end

        r.each_slice(2).to_a
      end

    end
  end
end
