require 'test_helper'

class Flappi::VersionPlanTest < ActiveSupport::TestCase

  context 'using v2_version_plan' do

    should 'return available_version_definitions' do
      expect_versions = Examples::V2VersionPlan.parse_versions('v2.0;v2.0-mobile;v2.1;v2.1-mobile')
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
        default_list =  Examples::V2VersionPlan.parse_versions('v2.1; v2.2')
        ver_list = Examples::V2VersionPlan.parse_versions('default; v2.1-flat', default_list)
        assert ver_list.include? Examples::V2VersionPlan.parse_version('v2.2')
      end

      should 'not detect not included' do
        ver_list = Examples::V2VersionPlan.parse_versions('v2.1; v2.1-flat;v2.2')
        refute ver_list.include? Examples::V2VersionPlan.parse_version('v2.3')
      end

    end

    context 'parse version rules' do
      should 'work without wildcard' do
        matched = Examples::V2VersionPlan.expand_version_rule :equals, 'v2.1-mobile'
        assert_equal 1, matched.size
        assert_equal "2.1.0-mobile", matched.first.to_s
      end

      should 'work with wildcard' do
        matched = Examples::V2VersionPlan.expand_version_rule :equals, 'v2.*.*-mobile'
        assert_equal 2, matched.size
        assert_equal '2.0.0-mobile', matched.first.to_s
        assert_equal '2.1.0-mobile', matched.last.to_s
      end
    end
  end


end
