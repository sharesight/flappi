# frozen_string_literal: true
require_relative 'test_helper'

class ::Flappi::ArgUtilsTest < MiniTest::Test
  context 'paired_args' do
    should 'return empty array for no args' do
      assert_equal [], Flappi::Utils::ArgUtils.paired_args
    end

    should 'extract a single pair' do
      assert_equal [[:a, 1]], Flappi::Utils::ArgUtils.paired_args(:a, 1)
    end

    should 'extract a single pair from a hash' do
      assert_equal [[:a, 1]], Flappi::Utils::ArgUtils.paired_args(a: 1)
    end

    should 'extract two pairs from a hash' do
      assert_equal [[:a, 1], [:b, 2]], Flappi::Utils::ArgUtils.paired_args(a: 1, b: 2)
    end

    should 'extract three pairs with repeat' do
      assert_equal [[:a, 1], [:b, 2], [:a, 3]], Flappi::Utils::ArgUtils.paired_args(:a, 1, :b, 2, :a, 3)
    end

    should 'extract three pairs from hashes' do
      assert_equal [[:a, 1], [:b, 2], [:a, 3]], Flappi::Utils::ArgUtils.paired_args({ a: 1, b: 2 }, a: 3)
    end
  end
end
