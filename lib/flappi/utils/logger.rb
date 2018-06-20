# frozen_string_literal: true

module Flappi
  module Utils
    module Logger
      def self.log(for_depth, msg)
        Flappi.configuration.logger_target.call(msg, for_depth) if Flappi.configuration.logger_target && for_depth <= (Flappi.configuration.logger_level || 1)
      end

      def self.e(msg)
        log(0, msg)
      end

      def self.w(msg)
        log(1, msg)
      end

      def self.i(msg)
        log(2, msg)
      end

      def self.d(msg)
        log(3, msg)
      end

      def self.t(msg)
        log(4, msg)
      end
    end
  end
end
