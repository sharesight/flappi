module Flappi
  module Utils
    module ParamTypes

      def validate_param(src, type)
        return true if src.blank?

        case type&.to_s
          when nil
            true
          when 'BOOLEAN'
            src.is_a?(TrueClass) || src.is_a?(FalseClass) || (src.size >= 1 && ['1','0','Y','N','T','F'].include?(src[0].to_s.upcase))
          when 'BigDecimal', 'Float'
            src.is_f?
          when 'Integer'
            src.is_i?
          when 'Date'
            return true if src.is_a?(::Date)
            Date.parse(src) rescue return false
            true
          else
            true # No idea how to parse
        end
      end

      def cast_param(src, type)
        # puts "cast_param #{src}, type #{type.to_s}"
        return nil if src.nil?

        case type&.to_s
          when nil
            nil
          when 'BOOLEAN'
            (src.is_a?(TrueClass) || src.is_a?(FalseClass)) ? src : (src.size >= 1 && ['1','Y','T'].include?(src[0].to_s.upcase))
          when 'BigDecimal', 'Float'
            src.to_f
          when 'Integer'
            src.to_i
          when 'Date'
            return src if src.is_a?(Date)
            Date.parse(src)
          else
            src
        end
      end
    end
  end
end
