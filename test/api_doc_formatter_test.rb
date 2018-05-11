# frozen_string_literal: true

require_relative 'test_helper'

class ::Flappi::ApiDocFormatterTest < MiniTest::Test
  context 'format' do
    should 'format and write to file' do
      Flappi::ApiDocFormatter.stubs(:format_to_text).returns('test')

      FileUtils.mkdir_p('tmp')
      test_file = 'tmp/test.txt'
      Flappi::ApiDocFormatter.format(OpenStruct.new(endpoint: { method_name: 'test' }), test_file)
      test_text = File.read(test_file)
      assert_equal 'test', test_text
    end
  end
end
