# frozen_string_literal: true

require 'test_helper'

class GeneratorTest < Minitest::Test
  include Metamarshal
  include SyntaxHelper

  def test_nil
    assert_equal "\x04\x080".b, generate(nil)
  end

  def test_true
    assert_equal "\x04\x08T".b, generate(true)
  end

  def test_false
    assert_equal "\x04\x08F".b, generate(false)
  end

  def test_fixnum_short
    assert_equal "\x04\x08i\x00".b, generate(0)
    assert_equal "\x04\x08i\x06".b, generate(1)
    assert_equal "\x04\x08i\x07".b, generate(2)
    assert_equal "\x04\x08i\x08".b, generate(3)
    assert_equal "\x04\x08i\x7D".b, generate(120)
    assert_equal "\x04\x08i\x7E".b, generate(121)
    assert_equal "\x04\x08i\x7F".b, generate(122)
    assert_equal "\x04\x08i\xFA".b, generate(-1)
    assert_equal "\x04\x08i\xF9".b, generate(-2)
    assert_equal "\x04\x08i\xF8".b, generate(-3)
    assert_equal "\x04\x08i\x83".b, generate(-120)
    assert_equal "\x04\x08i\x82".b, generate(-121)
    assert_equal "\x04\x08i\x81".b, generate(-122)
    assert_equal "\x04\x08i\x80".b, generate(-123)
  end

  def test_fixnum_long
    assert_equal "\x04\x08i\x01\x7B".b, generate(123)
    assert_equal "\x04\x08i\x01\xEA".b, generate(234)
    assert_equal "\x04\x08i\x02\xD2\x04".b, generate(1_234)
    assert_equal "\x04\x08i\x02\x07\x87".b, generate(34_567)
    assert_equal "\x04\x08i\x03\x4E\x61\xBC".b, generate(12_345_678)
    assert_equal "\x04\x08i\x04\xFF\xFF\xFF\x3F".b, generate(1_073_741_823)
    assert_equal "\x04\x08i\xFF\x84".b, generate(-124)
    assert_equal "\x04\x08i\xFF\x16".b, generate(-234)
    assert_equal "\x04\x08i\xFE\x2E\xFB".b, generate(-1_234)
    assert_equal "\x04\x08i\xFE\xF9\x78".b, generate(-34_567)
    assert_equal "\x04\x08i\xFD\xB2\x9E\x43".b, generate(-12_345_678)
    assert_equal "\x04\x08i\xFC\x00\x00\x00\xC0".b, generate(-1_073_741_824)
  end

  def test_array
    assert_equal(
      "\x04\x08[\x08i\x06i\x07i\x08".b,
      generate(MetaArray.new([1, 2, 3]))
    )
  end

  def test_link
    cycle1 = MetaArray.new([]).tap do |a|
      a.data << a
    end
    cycle2 = MetaArray.new([]).tap do |a|
      a.data << MetaArray.new([a])
    end
    wrapped1_cycle1 = MetaArray.new([cycle1])
    wrapped1_cycle2 = MetaArray.new([cycle2])
    assert_equal "\x04\x08[\x06@\x00".b, generate(cycle1)
    assert_equal "\x04\x08[\x06[\x06@\x00".b, generate(cycle2)
    assert_equal "\x04\x08[\x06[\x06@\x06".b, generate(wrapped1_cycle1)
    assert_equal "\x04\x08[\x06[\x06[\x06@\x06".b, generate(wrapped1_cycle2)

    non_shared = MetaArray.new([MetaArray.new([0]), MetaArray.new([0])])
    shared = MetaArray.new([MetaArray.new([0])] * 2)
    assert_equal "\x04\x08[\x07[\x06i\x00[\x06i\x00".b, generate(non_shared)
    assert_equal "\x04\x08[\x07[\x06i\x00@\x06".b, generate(shared)
  end
end
