# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../examples/exercise4'

module Integration
  class Exercise4DocoTest < Minitest::Test
    context 'Documentation of Exercise1' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'document our endpoint' do
        doc_data = ::Flappi::BuilderFactory.document(::Examples::Exercise4, nil)
        doc_text = ::Flappi::ApiDocFormatter.format_to_text(doc_data)

        expected_doc_text = File.read('test/examples/exercise4_doc.rb')
        # File.write 'test/examples/NEW_exercise4_doc.rb', doc_text
        assert_equal expected_doc_text.to_s, doc_text.to_s
      end
    end
  end
end
