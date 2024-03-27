# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../examples/version_plan'
require_relative '../examples/exercise_model'
require_relative '../examples/exercise12_skipped'

module Integration
  class Exercise12DocoTest < Minitest::Test
    context 'Documentation of Exercise12' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = Examples::VersionPlan
        end
      end

      should 'not document our endpoint' do
        doc_data = ::Flappi::BuilderFactory.document(::Examples::Exercise12Skipped, 'v2.0-mobile')
        doc_text = ::Flappi::ApiDocFormatter.format_to_text(doc_data)

        expected_doc_text = ''
        assert_equal spaceless(expected_doc_text), spaceless(doc_text.to_s)
      end
    end

    private

    def spaceless(s)
      s.gsub(/ +/, ' ').gsub(/^ *$/, '')
    end
  end
end
