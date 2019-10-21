require "test_helper"

class MetamarshalTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Metamarshal::VERSION
  end

  def test_parse_nil
    assert_nil ::Metamarshal.parse("\x04\x080")
  end
end
