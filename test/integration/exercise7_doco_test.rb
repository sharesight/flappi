# frozen_string_literal: true

require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise7_param'

module Integration
  class Exercise7DocoTest < Minitest::Test
    context 'Documentation of Exercise7' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'document endpoint with nested parameters' do
        doc_data = ::Flappi::BuilderFactory.document(::Examples::Exercise7Param, nil)
        doc_text = ::Flappi::ApiDocFormatter.format_to_text(doc_data)

        expected_doc_text = File.read('test/examples/exercise7_doc.rb')
        # File.write 'test/examples/NEW_exercise7_doc.rb', doc_text
        assert_equal expected_doc_text.to_s, doc_text.to_s
      end
    end
  end
end
