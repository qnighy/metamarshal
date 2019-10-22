require "test_helper"

class MetamarshalTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Metamarshal::VERSION
  end

  def test_parse_nil
    assert_nil ::Metamarshal.parse("\x04\x080")
  end

  def test_major_mismatch
    assert_raises(TypeError, "incompatible marshal file format (can't be read)\n\tformat version 4.8 required; 3.8 given") do
      ::Metamarshal.parse("\x03\x080")
    end
    assert_raises(TypeError, "incompatible marshal file format (can't be read)\n\tformat version 4.8 required; 5.8 given") do
      ::Metamarshal.parse("\x05\x080")
    end
  end

  def test_minor_mismatch
    assert_raises(TypeError, "incompatible marshal file format (can't be read)\n\tformat version 4.8 required; 4.9 given") do
      ::Metamarshal.parse("\x04\x090")
    end
    # TODO: check 4.7 being warned
  end

  def test_short_signature
    assert_raises(ArgumentError, "marshal data too short") do
      ::Metamarshal.parse("")
    end
    assert_raises(ArgumentError, "marshal data too short") do
      ::Metamarshal.parse("\x04")
    end
  end
end
