# frozen_string_literal: true

require_relative '../test_helper'

require 'pp'

require_relative '../examples/version_plan'
require_relative '../examples/exercise_model'
require_relative '../examples/exercise2_versioned'

module Integration
  class Exercise2DocoTest < MiniTest::Test
    context 'Documentation of Exercise2' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = Examples::VersionPlan
        end
      end

      should 'document our endpoint' do
        doc_data = ::Flappi::BuilderFactory.document(::Examples::Exercise2Versioned, 'v2.0-mobile')
        doc_text = ::Flappi::ApiDocFormatter.format_to_text(doc_data)

        expected_doc_text = File.read('test/examples/exercise2_2.0_doc.rb')
        # File.write 'test/examples/NEW_exercise2_2.0_doc.rb', spaceless(doc_text.to_s)
        assert_equal spaceless(expected_doc_text.to_s), spaceless(doc_text.to_s)
      end
    end

    def spaceless(s)
      s.gsub(/ +/, ' ').gsub(/^ *$/,'')
    end
  end
end
