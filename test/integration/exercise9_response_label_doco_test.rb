# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../examples/exercise9'

module Integration
  class Exercise9ResponseLabelDocoTest < Minitest::Test
    context 'Documentation of Exercise9' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'document our endpoint' do
        doc_data = ::Flappi::BuilderFactory.document(::Examples::Exercise9, nil)
        doc_text = ::Flappi::ApiDocFormatter.format_to_text(doc_data)

        expected_doc_text = File.read('test/examples/exercise9_doc.rb')
        # File.write 'test/examples/NEW_exercise9_doc.rb', doc_text
        assert_equal expected_doc_text.to_s, doc_text.to_s
      end
    end
  end
end
