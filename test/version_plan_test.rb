# frozen_string_literal: true

require_relative 'test_helper'

require_relative 'examples/version_plan'

class Flappi::VersionPlanTest < Minitest::Test
  context 'using version_plan' do
    should 'return available_version_definitions' do
      expect_versions = Examples::VersionPlan.parse_versions('v2.0;v2.0-mobile;v2.1;v2.1-ember;v2.1-flat;v2.1-mobile')

      expect_versions.each do |version|
        assert_includes Examples::VersionPlan.available_version_definitions, version
      end
    end

    should 'parse and stringise a version' do
      ver = Examples::VersionPlan.parse_version('v2.1.2')
      assert_equal '2.1.2', ver.to_s

      ver = Examples::VersionPlan.parse_version('v2.1.2-flat')
      assert_equal '2.1.2-flat', ver.to_s
    end

    should 'parse versions with wildcards' do
      ver = Examples::VersionPlan.parse_version('v2.*.2')
      assert_equal '2.*.2', ver.to_s

      ver = Examples::VersionPlan.parse_version('v2.1.2-*')
      assert_equal '2.1.2-*', ver.to_s
    end

    should 'parse and stringise a minor version' do
      ver = Examples::VersionPlan.parse_version('m2.1')
      assert_equal '2.1', ver.to_s

      ver = Examples::VersionPlan.parse_version('m2.1-ember')
      assert_equal '2.1-ember', ver.to_s
    end

    # rubocop:disable Minitest/AssertEqual
    context 'version equality' do
      should 'compare same without wildcard' do
        v1 = Examples::VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::VersionPlan.parse_version('m2.1-ember')
        assert v1 == v2
      end

      should 'compare different without wildcard' do
        v1 = Examples::VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::VersionPlan.parse_version('m2.2-ember')
        refute v1 == v2
      end

      should 'compare same with wildcard' do
        v1 = Examples::VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::VersionPlan.parse_version('m2.1-*')
        assert v1 == v2
      end

      should 'compare different with wildcard' do
        v1 = Examples::VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::VersionPlan.parse_version('m2.*-flat')
        refute v1 == v2
      end
    end
    # rubocop:enable Minitest/AssertEqual

    # rubocop:disable Minitest/AssertIncludes
    # rubocop:disable Minitest/RefuteIncludes
    context 'version list include' do
      should 'detect included' do
        ver_list = Examples::VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2')
        assert ver_list.include? Examples::VersionPlan.parse_version('v2.1-flat')
      end

      should 'detect included in defaults' do
        default_list = Examples::VersionPlan.parse_versions('v2.1; v2.2')
        ver_list = Examples::VersionPlan.parse_versions('default; v2.1-flat', default_list)
        assert ver_list.include? Examples::VersionPlan.parse_version('v2.2')
      end

      should 'detect included in stringy defaults' do
        ver_list = Examples::VersionPlan.parse_versions('default; v2.1-flat', 'v2.1; v2.2')
        assert ver_list.include? Examples::VersionPlan.parse_version('v2.2')
      end

      should 'not detect not included' do
        ver_list = Examples::VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2')
        refute ver_list.include? Examples::VersionPlan.parse_version('v2.3')
      end
    end
    # rubocop:enable Minitest/RefuteIncludes
    # rubocop:enable Minitest/AssertIncludes

    context 'parse_versions' do
      should 'parse and normalise' do
        ver_list = Examples::VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2', [], true)
        assert_equal '[2.1.0, 2.1.0-flat, 2.2.0]', ver_list.to_s
      end

      should 'parse and not normalise' do
        ver_list = Examples::VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2', [], false)
        assert_equal '[2.1, 2.1-flat, 2.2]', ver_list.to_s
      end
    end

    context 'minimum_version' do
      should 'return the lowest version definition without a flavour or with the lowest value in sort if all have flavours' do
        assert_equal '2.0.0', Examples::VersionPlan.minimum_version.to_s
      end
    end

    context 'parse version rules' do
      should 'work without wildcard' do
        matched = Examples::VersionPlan.expand_version_rule equals: 'v2.1-mobile'
        assert_equal 1, matched.size
        assert_equal ['2.1.0-mobile'], matched.map(&:to_s)
      end

      should 'work with wildcard' do
        matched = Examples::VersionPlan.expand_version_rule equals: 'v2.*.*-mobile'
        assert_equal 2, matched.size
        assert_equal ['2.0.0-mobile', '2.1.0-mobile'], matched.map(&:to_s)
      end

      should 'work with ne' do
        matched = Examples::VersionPlan.expand_version_rule ne: 'v2.1-mobile'
        assert_equal 6, matched.size
        assert_equal ['2.0.0', '2.0.0-mobile', '2.1.0', '2.1.0-ember', '2.1.0-flat', '3.0.0'], matched.map(&:to_s)
      end

      should 'work with multiple rules ored together' do
        matched = Examples::VersionPlan.expand_version_rule equals: 'v2.0-', gte: 'v2.1-*'
        assert_equal 6, matched.size
        assert_equal ['2.0.0', '2.1.0', '2.1.0-ember', '2.1.0-flat', '2.1.0-mobile', '3.0.0'], matched.map(&:to_s)
      end

      should 'work with after' do
        matched = Examples::VersionPlan.expand_version_rule after: 'v2.0-'

        assert_equal 2, matched.size
        assert_equal ['2.1.0', '3.0.0'], matched.map(&:to_s)
      end

      should 'work with gte' do
        matched = Examples::VersionPlan.expand_version_rule gte: 'v2.0-'

        assert_equal 3, matched.size
        assert_equal ['2.0.0', '2.1.0', '3.0.0'], matched.map(&:to_s)
      end

      should 'work with before' do
        matched = Examples::VersionPlan.expand_version_rule before: 'v2.1-*'

        assert_equal 2, matched.size
        assert_equal ['2.0.0', '2.0.0-mobile'], matched.map(&:to_s)
      end

      should 'fail for unsupported rule type' do
        exception = assert_raises(RuntimeError) { Examples::VersionPlan.expand_version_rule :greater_than, 'v2.*.*-mobile' }
        assert_equal 'Rule type greater_than not supported yet, sorry...', exception.message
      end
    end
  end
end
