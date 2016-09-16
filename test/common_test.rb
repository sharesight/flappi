require 'minitest/autorun'
require 'shoulda'
require 'pp'

require 'flappi'

class ::Flappi::ResponseBuilderTest < MiniTest::Test

  context 'extract_definition_args' do
    setup do
      @common_test = Object.new
      @common_test.extend(Flappi::Common)
    end

    should 'extract a single name from an array' do
      assert_equal({'name' => :a}, @common_test.extract_definition_args([:a]))
    end

    should 'extract a single name from a scalar' do
      assert_equal({'name' => :a}, @common_test.extract_definition_args(:a))
    end

    should 'extract a name and value' do
      assert_equal({'name' => :a, 'value' => 101}, @common_test.extract_definition_args([:a, 101]))
    end

    should 'pass through a hash' do
      assert_equal({'name' => :a, 'value' => 101}, @common_test.extract_definition_args({name: :a, value: 101}))
    end

  end

end
