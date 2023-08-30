# frozen_string_literal: true

require_relative 'test_helper'

class Flappi::VersionsTest < Minitest::Test
  context 'versions' do
    setup do
      @versions = Flappi::Versions.new [Flappi::Version.new([1, 0, 0], nil, nil), Flappi::Version.new([2, 0, 0], nil, nil)]
    end

    # rubocop:disable Minitest/AssertIncludes
    # rubocop:disable Minitest/RefuteIncludes
    should 'supports include?' do
      assert @versions.include? Flappi::Version.new([1, 0, 0], nil, nil)
      refute @versions.include? Flappi::Version.new([1, 1, 0], nil, nil)
    end
    # rubocop:enable Minitest/RefuteIncludes
    # rubocop:enable Minitest/AssertIncludes

    should 'supports to_s?' do
      assert_equal '[1.0.0, 2.0.0]', @versions.to_s
    end

    should 'supports equality' do
      assert_equal Flappi::Versions.new([Flappi::Version.new([1, 0, 0], nil, nil), Flappi::Version.new([2, 0, 0], nil, nil)]), @versions
      refute_equal Flappi::Versions.new([Flappi::Version.new([1, 0, 1], nil, nil), Flappi::Version.new([2, 0, 0], nil, nil)]), @versions
    end
  end
end
