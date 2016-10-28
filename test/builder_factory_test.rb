# frozen_string_literal: true
require_relative 'test_helper'
require 'pp'

class ::Flappi::BuilderFactoryTest < MiniTest::Test
  context 'validate_parameters' do
    setup do
      @defined_parameters = [
        { name: 'a' },
        { name: 'b', type: Float },
        { name: 'c', validation_block: ->(p) { (p.to_i / 10) == 3 ? nil : "c(#{p}) must be 3 * 10ⁿ" } },
        { name: 'd', type: Date, optional: true }
      ]
    end

    should 'pass and cast correct parameters' do
      actual_params = { 'a' => 'hello', 'b' => '1.23', 'c' => '30' }
      assert_nil Flappi::BuilderFactory.validate_parameters(actual_params, @defined_parameters)
      assert_equal({ 'a' => 'hello', 'b' => 1.23, 'c' => '30' }, actual_params, 'Cast happened')
    end

    should 'detect undefined required parameter' do
      assert_equal 'Parameter a is required',
                   Flappi::BuilderFactory.validate_parameters({ 'b' => '3.142', 'c' => '30' }, @defined_parameters)
    end

    should 'detect incorrect type' do
      assert_equal 'Parameter d must be of type Date',
                   Flappi::BuilderFactory.validate_parameters({ 'a' => 'hello', 'b' => '1.23', 'c' => '30', 'd' => '2017-13-01' },
                                                              @defined_parameters)
    end

    should 'detect error from validation block' do
      assert_equal 'Parameter c failed validation: c(29) must be 3 * 10ⁿ',
                   Flappi::BuilderFactory.validate_parameters({ 'a' => 'hello', 'b' => '1.23', 'c' => '29', 'd' => '2017-13-01' },
                                                              @defined_parameters)
    end
  end

  context 'apply_default_parameters' do
    setup do
      @defined_parameters = [
        { name: 'a' },
        { name: 'b', type: Float, default: 888.88 }
      ]
    end

    should 'put defaults into actuals' do
      actual_params = { 'a' => 'hello' }
      Flappi::BuilderFactory.apply_default_parameters(actual_params, @defined_parameters)
      assert_equal({ 'a' => 'hello', 'b' => 888.88 }, actual_params)
    end

    should 'apply default when parameter empty' do
      actual_params = { 'a' => 'hello', 'b' => '' }
      Flappi::BuilderFactory.apply_default_parameters(actual_params, @defined_parameters)
      assert_equal({ 'a' => 'hello', 'b' => 888.88 }, actual_params)
    end
  end
end
