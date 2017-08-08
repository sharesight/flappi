# frozen_string_literal: true
module Flappi
  class ParamProcessor
    def initialize(param_def)
      @param_def = param_def
    end

    # Call block to process a parameter
    #
    #   @yield A block that will be called to process the parameter
    #   @yieldparam  [Object] param the actual parameter value before processing
    #   @yieldreturn [String] the processed parameter
    def processor(&block)
      @param_def[:processor_block] = block
      self
    end

    # Call block to validate a parameter
    #
    #   @yield A block that will be called to validate the parameter
    #   @yieldparam  [Object] param the actual parameter value to validate
    #   @yieldreturn [String] nil if the parameter is valid, else a failure message
    def validator(&block)
      @param_def[:validation_block] = block
      self
    end
  end
end
