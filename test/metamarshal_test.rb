require "test_helper"

class MetamarshalTest < Minitest::Test
  include SyntaxHelper

  def test_that_it_has_a_version_number
    refute_nil ::Metamarshal::VERSION
  end

  def test_parse_call
    assert_equal 42, ::Metamarshal.parse("\x04\x08i\x2F")
  end

  def test_parse_module_method
    klass = Class.new do
      include ::Metamarshal

      def answer
        parse("\x04\x08i\x2F")
      end
    end
    assert_equal 42, klass.new.answer
  end
end
