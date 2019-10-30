# frozen_string_literal: true

require_relative '../test_helper'

class ::Flappi::HashKeyUtilsTest < MiniTest::Test
  ['symbol', 'string', 'mixed'].each do |key_type|

    context "#{key_type} keys" do
      setup do
        @hash = case key_type
               when 'symbol'
                 { a: { b: { c: 100, d: 200 }, e: 50 }, f: 6 }
               when 'string'
                 { 'a' => { 'b' => { 'c' => 100, 'd' => 200 }, 'e' => 50 }, 'f' => 6 }
               when 'mixed'
                 { 'a' => { :b => { 'c' => 100, 'd' => 200 }, :e => 50 }, 'f' => 6 }
               end

      end

      context 'dig_indifferent' do
        should 'return nil when nil @hash' do
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(nil)
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(nil, :z)
        end

        should 'return @hash when no items' do
          assert_equal @hash, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash)
        end

        should 'return nil when path unmatched' do
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :z)
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :z)
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :b, :z)
        end

        should 'return nil when string path unmatched' do
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'z')
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'a', 'z')
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'a', 'b', 'z')
        end

        should 'return nil when mixed path unmatched' do
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'a', :z)
          assert_nil Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, 'b', 'z')
        end

        should 'return matched end value' do
          assert_equal 100, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :b, :c)
          assert_equal 50, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :e)
          assert_equal 6, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :f)
        end

        should 'return matched end value by string' do
          assert_equal 100, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'a', 'b', 'c')
          assert_equal 50, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'a', 'e')
          assert_equal 6, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'f')
        end

        should 'return matched end value by mixed' do
          assert_equal 100, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'a', :b, 'c')
          assert_equal 50, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, 'e')
          assert_equal 6, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, 'f')
        end
      end

      context 'bury_indifferent' do
        should 'store in an empty @hash by symbol' do
          ehash = {}
          Flappi::Utils::HashKeyUtils.bury_indifferent(ehash, 111, :a)
          assert_equal({ a: 111 }, ehash)
        end

        should 'store in an empty @hash by string' do
          ehash = {}
          Flappi::Utils::HashKeyUtils.bury_indifferent(ehash, 111, 'a')
          assert_equal({ 'a' => 111 }, ehash)
        end

        should 'store new entry under @hash by string' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 222, 'a', 'b', 'x')
          assert_equal 222, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :b)['x']
        end

        should 'store new entry under @hash by symbol' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 333, :a, :b, :x)
          assert_equal 333, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :b)[:x]
        end

        should 'update existing entry under @hash by string' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 201, 'a', 'b', 'd')
          assert_equal 201, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :b, :d)
        end

        should 'update existing entry under @hash by symbol' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 202, :a, :b, :d)
          assert_equal 202, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :a, :b, :d)
        end

        should 'update existing top level entry under @hash by string' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 601, 'f')
          assert_equal 601, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :f)
        end

        should 'update existing top level entry under @hash by symbol' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 602, :f)
          assert_equal 602, Flappi::Utils::HashKeyUtils.dig_indifferent(@hash, :f)
        end

        should 'store new top level entry under @hash by string' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 7, 'z')
          assert_equal 7, @hash['z']
        end

        should 'store new top level entry under @hash by symbol' do
          Flappi::Utils::HashKeyUtils.bury_indifferent(@hash, 8, :z)
          assert_equal 8, @hash[:z]
        end

      end
    end
  end
end
