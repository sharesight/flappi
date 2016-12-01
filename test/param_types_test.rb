# frozen_string_literal: true
require_relative 'test_helper'

class Flappi::VersionsTest < MiniTest::Test
  context 'when extended' do
    setup do
      @param_types_test = Object.new
      @param_types_test.extend(Flappi::Utils::ParamTypes)
    end

    context 'validate_param' do
      should 'accept anything for nil type' do
        assert @param_types_test.validate_param('anything', nil)
      end

      should 'accept valid values for boolean type' do
        assert @param_types_test.validate_param(true, 'BOOLEAN')
        assert @param_types_test.validate_param(false, 'BOOLEAN')
        assert @param_types_test.validate_param('1', 'BOOLEAN')
        assert @param_types_test.validate_param('Y', 'BOOLEAN')
        assert @param_types_test.validate_param('N', 'BOOLEAN')
        assert @param_types_test.validate_param(1, 'BOOLEAN')
        assert @param_types_test.validate_param(0, 'BOOLEAN')
      end

      should 'reject empty param' do
        assert @param_types_test.validate_param('', 'Wibble')
        refute @param_types_test.validate_param(nil, 'Wibble')
        refute @param_types_test.validate_param('', 'Date')
      end

      should 'reject invalid values for boolean type' do
        refute @param_types_test.validate_param('9', 'BOOLEAN')
        refute @param_types_test.validate_param('hello', 'BOOLEAN')
        refute @param_types_test.validate_param('boo', 'BOOLEAN')
      end

      should 'accept valid dates' do
        assert @param_types_test.validate_param('2012-May-15', 'Date')
        assert @param_types_test.validate_param('2015-01-02', 'Date')
        assert @param_types_test.validate_param('29/02/2000', 'Date')
        assert @param_types_test.validate_param('1997-07-16T19:20+01:00', 'Date')
      end

      should 'reject invalid dates' do
        refute @param_types_test.validate_param('2012-Cob-15', 'Date')
        refute @param_types_test.validate_param('2015-15-02', 'Date')
        refute @param_types_test.validate_param('29/02/2001', 'Date')
        refute @param_types_test.validate_param('Hello!', 'Date')
      end

      should 'accept anything for incomprehensible type' do
        assert @param_types_test.validate_param('anything', 'Wibble')
      end

      context "Hash" do
        should 'reject anything but hash' do
          assert @param_types_test.validate_param({}, 'Hash')
          refute @param_types_test.validate_param("{}", 'Hash')
          refute @param_types_test.validate_param([1,2], 'Hash')
          refute @param_types_test.validate_param("i'm a string", 'Hash')
          refute @param_types_test.validate_param(1, 'Hash')
        end
      end
    end

    context 'cast_param' do
      should 'return source value for nil type' do
        assert_equal 'anything', @param_types_test.cast_param('anything', nil)
      end

      should 'convert boolean type to boolean' do
        assert @param_types_test.cast_param(true, 'BOOLEAN')
        refute @param_types_test.cast_param(false, 'BOOLEAN')
        assert @param_types_test.cast_param('1', 'BOOLEAN')
        assert @param_types_test.cast_param('Y', 'BOOLEAN')
        refute @param_types_test.cast_param('N', 'BOOLEAN')
        assert @param_types_test.cast_param(1, 'BOOLEAN')
        refute @param_types_test.cast_param(0, 'BOOLEAN')
      end

      should 'convert valid dates' do
        assert_equal Date.new(2012, 0o5, 15), @param_types_test.cast_param('2012-May-15', 'Date')
        assert_equal Date.new(2015, 0o1, 0o2), @param_types_test.cast_param('2015-01-02', 'Date')
        assert_equal Date.new(2000, 0o2, 29), @param_types_test.cast_param('29/02/2000', 'Date')
        assert_equal Date.new(1997, 0o7, 16), @param_types_test.cast_param('1997-07-16T19:20+01:00', 'Date')
      end

      should 'pass through when incomprehensible type' do
        assert_equal 'anything', @param_types_test.cast_param('anything', 'Wibble')
      end
    end
  end
end
