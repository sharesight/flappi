# frozen_string_literal: true

require_relative 'test_helper'

require_relative 'examples/version_plan'

class Flappi::VersionTest < Minitest::Test
  context 'initialize' do
    should 'set flavour to :_blank when nil' do
      v = Flappi::Version.new([1, 0], nil, nil)
      assert_equal :_blank, v.flavour
    end

    should 'set flavour to a symbol' do
      v = Flappi::Version.new([1, 0], 'mobile', nil)
      assert_equal :mobile, v.flavour
    end
  end

  context 'normalise with example version plan' do
    should 'return a matching value when same number of components' do
      v = Flappi::Version.new([2, 0, 0], nil, Examples::VersionPlan)
      assert_equal v, v.normalise
    end

    should 'normalize to a defined version' do
      v = Flappi::Version.new([2], nil, Examples::VersionPlan)
      assert_equal '2.0.0', v.normalise.to_s
    end
  end

  context 'to_s' do
    should 'return a version with flavour' do
      v = Flappi::Version.new([2, 0], :mobile, Examples::VersionPlan)
      assert_equal '2.0-mobile', v.to_s
    end
  end

  # rubocop:disable Minitest/AssertEqual
  context 'equal with ==' do
    should 'return true when exactly same' do
      va = Flappi::Version.new([1, 0], nil, nil)
      vb = Flappi::Version.new([1, 0], nil, nil)
      assert va == vb
    end

    should 'return false when not same' do
      v1_0 = Flappi::Version.new([1, 0], nil, nil)
      v1_1 = Flappi::Version.new([1, 1], nil, nil)
      refute v1_0 == v1_1
    end

    should 'treat points not provided as zero' do
      va = Flappi::Version.new([1], nil, nil)
      vb = Flappi::Version.new([1, 0, 0], nil, nil)
      assert va == vb

      vc = Flappi::Version.new([1, 0, 1], nil, nil)
      refute vc == vb
    end

    should 'match with wildcard' do
      va = Flappi::Version.new([1, '*'], nil, nil)
      vb = Flappi::Version.new([1, 3], nil, nil)
      assert va == vb
    end

    should 'match flavours' do
      va = Flappi::Version.new([1, 0], 'mobile', nil)
      vb = Flappi::Version.new([1, 0], 'mobile', nil)
      assert va == vb

      vc = Flappi::Version.new([1, 0], nil, nil)
      refute va == vc
    end

    should 'match wildcard flavours' do
      va = Flappi::Version.new([1, 0], 'mobile', nil)
      vb = Flappi::Version.new([1, 0], '*', nil)
      assert va == vb
    end
  end
  # rubocop:enable Minitest/AssertEqual

  context 'not equal with !=' do
    should 'return falsewhen exactly same' do
      va = Flappi::Version.new([1, 0], nil, nil)
      vb = Flappi::Version.new([1, 0], nil, nil)
      refute va != vb
    end
  end

  context 'comparators' do
    setup do
      @v2_0 = Flappi::Version.new([2, 0], nil, nil)
      @v1_0 = Flappi::Version.new([1, 0], nil, nil)
      @v1_1 = Flappi::Version.new([1, 1], nil, nil)
    end

    context 'with >' do
      should 'return true when greater than on first' do
        assert @v2_0 > @v1_0
      end

      should 'return false when less than on first' do
        refute @v1_0 > @v2_0
      end

      should 'return true when greater than on second' do
        assert @v1_1 > @v1_0
      end

      should 'return false when less than on second' do
        refute @v1_0 > @v1_1
      end

      should 'return false when equal' do
        refute @v1_1 > @v1_1
      end

      should 'match flavours' do
        v1_1m = Flappi::Version.new([1, 1], 'mobile', nil)
        v1_0m = Flappi::Version.new([1, 0], 'mobile', nil)
        assert v1_1m > v1_0m
      end

      should 'match wildcard flavours' do
        v1_1m = Flappi::Version.new([1, 1], 'mobile', nil)
        v1_0star = Flappi::Version.new([1, 0], '*', nil)
        assert v1_1m > v1_0star
      end
    end

    context 'with >=' do
      should 'return true when gt or equal' do
        assert @v2_0 >= @v1_0
        assert @v2_0 >= Flappi::Version.new([2, 0], nil, nil)
        refute @v1_1 >= @v2_0
      end
    end

    context 'with <' do
      should 'return true when less than' do
        refute @v2_0 < @v1_0
        refute @v2_0 < Flappi::Version.new([2, 0], nil, nil)
        assert @v1_1 < @v2_0
      end
    end

    context 'with <=' do
      should 'return true when lt or equal' do
        refute @v2_0 <= @v1_0
        assert @v2_0 <= Flappi::Version.new([2, 0], nil, nil)
        assert @v1_1 <= @v2_0
      end
    end
  end
end
