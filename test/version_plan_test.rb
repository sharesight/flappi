# frozen_string_literal: true

require_relative 'test_helper'

require_relative 'examples/v2_version_plan'

class Flappi::VersionPlanTest < MiniTest::Test
  context 'using v2_version_plan' do
    should 'return available_version_definitions' do
      expect_versions = Examples::V2VersionPlan.parse_versions('v2.0;v2.0-mobile;v2.1;v2.1-ember;v2.1-flat;v2.1-mobile')
      assert_equal expect_versions,
                   Examples::V2VersionPlan.available_version_definitions
    end

    should 'parse and stringise a version' do
      ver = Examples::V2VersionPlan.parse_version('v2.1.2')
      assert_equal '2.1.2', ver.to_s

      ver = Examples::V2VersionPlan.parse_version('v2.1.2-flat')
      assert_equal '2.1.2-flat', ver.to_s
    end

    should 'parse versions with wildcards' do
      ver = Examples::V2VersionPlan.parse_version('v2.*.2')
      assert_equal '2.*.2', ver.to_s

      ver = Examples::V2VersionPlan.parse_version('v2.1.2-*')
      assert_equal '2.1.2-*', ver.to_s
    end

    should 'parse and stringise a minor version' do
      ver = Examples::V2VersionPlan.parse_version('m2.1')
      assert_equal '2.1', ver.to_s

      ver = Examples::V2VersionPlan.parse_version('m2.1-ember')
      assert_equal '2.1-ember', ver.to_s
    end

    context 'version equality' do
      should 'compare same without wildcard' do
        v1 = Examples::V2VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::V2VersionPlan.parse_version('m2.1-ember')
        assert v1 == v2
      end

      should 'compare different without wildcard' do
        v1 = Examples::V2VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::V2VersionPlan.parse_version('m2.2-ember')
        refute v1 == v2
      end

      should 'compare same with wildcard' do
        v1 = Examples::V2VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::V2VersionPlan.parse_version('m2.1-*')
        assert v1 == v2
      end

      should 'compare different with wildcard' do
        v1 = Examples::V2VersionPlan.parse_version('m2.1-ember')
        v2 = Examples::V2VersionPlan.parse_version('m2.*-flat')
        refute v1 == v2
      end
    end

    context 'version list include' do
      should 'detect included' do
        ver_list = Examples::V2VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2')
        assert ver_list.include? Examples::V2VersionPlan.parse_version('v2.1-flat')
      end

      should 'detect included in defaults' do
        default_list = Examples::V2VersionPlan.parse_versions('v2.1; v2.2')
        ver_list = Examples::V2VersionPlan.parse_versions('default; v2.1-flat', default_list)
        assert ver_list.include? Examples::V2VersionPlan.parse_version('v2.2')
      end

      should 'detect included in stringy defaults' do
        ver_list = Examples::V2VersionPlan.parse_versions('default; v2.1-flat', 'v2.1; v2.2')
        assert ver_list.include? Examples::V2VersionPlan.parse_version('v2.2')
      end

      should 'not detect not included' do
        ver_list = Examples::V2VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2')
        refute ver_list.include? Examples::V2VersionPlan.parse_version('v2.3')
      end
    end

    context 'parse_versions' do
      should 'parse and normalise' do
        ver_list = Examples::V2VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2', [], true)
        assert_equal '[2.1.0, 2.1.0-flat, 2.2.0]', ver_list.to_s
      end

      should 'parse and not normalise' do
        ver_list = Examples::V2VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2', [], false)
        assert_equal '[2.1, 2.1-flat, 2.2]', ver_list.to_s
      end
    end

    context 'minimum_version' do
      should 'return the lowest version definition without a flavour or with the lowest value in sort if all have flavours' do
        assert_equal '2.0.0', Examples::V2VersionPlan.minimum_version.to_s
      end
    end

    context 'parse version rules' do
      should 'work without wildcard' do
        matched = Examples::V2VersionPlan.expand_version_rule equals: 'v2.1-mobile'
        assert_equal 1, matched.size
        assert_equal matched.map(&:to_s), ['2.1.0-mobile']
      end

      should 'work with wildcard' do
        matched = Examples::V2VersionPlan.expand_version_rule equals: 'v2.*.*-mobile'
        assert_equal 2, matched.size
        assert_equal matched.map(&:to_s), ['2.0.0-mobile', '2.1.0-mobile']
      end

      should 'work with ne' do
        matched = Examples::V2VersionPlan.expand_version_rule ne: 'v2.1-mobile'
        assert_equal 5, matched.size
        assert_equal matched.map(&:to_s), ['2.0.0', '2.0.0-mobile', '2.1.0', '2.1.0-ember', '2.1.0-flat']
      end

      should 'work with multiple rules ored together' do
        matched = Examples::V2VersionPlan.expand_version_rule equals: 'v2.0-', gte: 'v2.1-*'
        assert_equal 5, matched.size
        assert_equal matched.map(&:to_s), ['2.0.0', '2.1.0', '2.1.0-ember', '2.1.0-flat', '2.1.0-mobile']
      end

      should 'work with after' do
        matched = Examples::V2VersionPlan.expand_version_rule after: 'v2.0-'

        assert_equal 1, matched.size
        assert_equal matched.map(&:to_s), ['2.1.0']
      end

      should 'work with gte' do
        matched = Examples::V2VersionPlan.expand_version_rule gte: 'v2.0-'

        assert_equal 2, matched.size
        assert_equal matched.map(&:to_s), ['2.0.0', '2.1.0']
      end

      should 'work with before' do
        matched = Examples::V2VersionPlan.expand_version_rule before: 'v2.1-*'

        assert_equal 2, matched.size
        assert_equal matched.map(&:to_s), ['2.0.0', '2.0.0-mobile']
      end

      should 'fail for unsupported rule type' do
        exception = assert_raises(RuntimeError) { Examples::V2VersionPlan.expand_version_rule :greater_than, 'v2.*.*-mobile' }
        assert_equal 'Rule type greater_than not supported yet, sorry...', exception.message
      end
    end
  end
end
