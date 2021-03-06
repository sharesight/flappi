# frozen_string_literal: true

module Flappi
  module Utils
    module ParamTypes
      def validate_param(src, type)
        return false if src.nil?

        case type&.to_s
        when 'Boolean'
          src.is_a?(TrueClass) || src.is_a?(FalseClass) || ['Y', 'N', '0', '1', 'T', 'F', 'YES', 'NO', 'TRUE', 'FALSE'].include?(src.to_s.upcase)
        when 'BigDecimal', 'Float'
          src.is_f?
        when 'Integer'
          src.is_i?
        when 'Date'
          return true if src.is_a?(::Date)

          begin
            Date.parse(src)
          rescue StandardError
            return false
          end
          true
        else
          true # No idea how to parse
        end
      end

      def cast_param(src, type, name = nil)
        # puts "cast_param #{src}, type #{type.to_s}"
        return nil if src.nil?

        case type&.to_s
        when 'Boolean'
          src.is_a?(TrueClass) || src.is_a?(FalseClass) ? src : (src.size >= 1 && %w[1 Y T].include?(src[0].to_s.upcase))
        when 'BigDecimal', 'Float'
          src.to_f
        when 'Integer'
          src.to_i
        when 'Date'
          return src if src.is_a?(Date)

          Date.parse(src)
        when 'Array'
          return src if src.is_a?(Array)

          array_parse(src)
        when 'String'
          src
        else
          Flappi::Utils::Logger.w "Cast to unrecognised param type #{type} for #{name}"
          src
        end
      end

      def array_parse(a)
        a = a[-1..2] if a.start_with?('[') and a.end_with?(']')

        a.split(',').map do |c|
          next c.to_f if c.to_f.to_s == c
          next c.to_i if c.to_i.to_s == c

          c.gsub(/^"/, '').gsub(/"\s*$/, '')
        end
      end
    end
  end
end
