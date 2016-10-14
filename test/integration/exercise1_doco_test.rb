require_relative '../test_helper'

require 'pp'

require_relative '../examples/exercise1'

module Integration
  class Exercise1ResponseTest < MiniTest::Test

    context 'Documentation of Exercise1' do
      setup do
        Flappi.configure do |conf|
          conf.version_plan = nil
        end
      end

      should 'document our endpoint' do

        doc_data = ::Flappi::BuilderFactory.document(::Examples::Exercise1, nil)
        doc_text = ::Flappi::ApiDocFormatter.format_to_text(doc_data)

        expected_doc_text = File.read('test/examples/exercise1_doc.rb')
        assert_equal expected_doc_text, doc_text
      end
    end

  end
end
