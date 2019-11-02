# frozen_string_literal: true

require 'test_helper'

# rubocop:disable Metrics/ClassLength
class ParseTest < Minitest::Test
  # rubocop:enable Metrics/ClassLength
  include Metamarshal
  include SyntaxHelper

  def test_parse_nil
    assert_nil parse("\x04\x080")
  end

  def test_parse_true
    assert_equal true, parse("\x04\x08T") # rubocop:disable Minitest/AssertTruthy
  end

  def test_parse_false
    assert_equal false, parse("\x04\x08F") # rubocop:disable Minitest/RefuteFalse
  end

  def test_parse_fixnum_short
    assert_equal 0, parse("\x04\x08i\x00")
    assert_equal 1, parse("\x04\x08i\x06")
    assert_equal 2, parse("\x04\x08i\x07")
    assert_equal 3, parse("\x04\x08i\x08")
    assert_equal 120, parse("\x04\x08i\x7D")
    assert_equal 121, parse("\x04\x08i\x7E")
    assert_equal 122, parse("\x04\x08i\x7F")
    assert_equal(-1, parse("\x04\x08i\xFA"))
    assert_equal(-2, parse("\x04\x08i\xF9"))
    assert_equal(-3, parse("\x04\x08i\xF8"))
    assert_equal(-120, parse("\x04\x08i\x83"))
    assert_equal(-121, parse("\x04\x08i\x82"))
    assert_equal(-122, parse("\x04\x08i\x81"))
    assert_equal(-123, parse("\x04\x08i\x80"))
  end

  def test_parse_fixnum_long
    assert_equal 123, parse("\x04\x08i\x01\x7B")
    assert_equal 234, parse("\x04\x08i\x01\xEA")
    assert_equal 1_234, parse("\x04\x08i\x02\xD2\x04")
    assert_equal 34_567, parse("\x04\x08i\x02\x07\x87")
    assert_equal 12_345_678, parse("\x04\x08i\x03\x4E\x61\xBC")
    assert_equal 1_073_741_823, parse("\x04\x08i\x04\xFF\xFF\xFF\x3F")
    assert_equal(-124, parse("\x04\x08i\xFF\x84"))
    assert_equal(-234, parse("\x04\x08i\xFF\x16"))
    assert_equal(-1_234, parse("\x04\x08i\xFE\x2E\xFB"))
    assert_equal(-34_567, parse("\x04\x08i\xFE\xF9\x78"))
    assert_equal(-12_345_678, parse("\x04\x08i\xFD\xB2\x9E\x43"))
    assert_equal(-1_073_741_824, parse("\x04\x08i\xFC\x00\x00\x00\xC0"))
  end

  def test_parse_symbol
    assert_equal(:"", parse("\x04\x08:\x00"))
    assert_equal(:foo, parse("\x04\x08:\x08foo"))
  end

  def test_parse_symlink
    assert_syn_isomorphic(
      MetaArray.new(%i[foo bar bar foo]),
      parse("\x04\x08[\x09:\x08foo:\x08bar;\x06;\x00")
    )
  end

  def test_parse_symlink_bad_index
    assert_raises(ArgumentError, 'bad symbol') do
      parse("\x04\x08;\x00")
    end
    assert_raises(ArgumentError, 'bad symbol') do
      parse("\x04\x08[\x07;\x00:\x08foo")
    end
  end

  def test_parse_array
    assert_syn_isomorphic(
      MetaArray.new([1, 2, 3]),
      parse("\x04\x08[\x08i\x06i\x07i\x08")
    )
  end

  def test_parse_link
    cycle1 = MetaArray.new([]).tap do |a|
      a.data << a
    end
    cycle2 = MetaArray.new([]).tap do |a|
      a.data << MetaArray.new([a])
    end
    wrapped1_cycle1 = MetaArray.new([cycle1])
    wrapped1_cycle2 = MetaArray.new([cycle2])
    assert_syn_isomorphic cycle1, parse("\x04\x08[\x06@\x00")
    refute_syn_isomorphic cycle1, parse("\x04\x08[\x06[\x06@\x00")
    refute_syn_isomorphic cycle1, parse("\x04\x08[\x06[\x06@\x06")
    refute_syn_isomorphic cycle1, parse("\x04\x08[\x06[\x06[\x06@\x06")
    refute_syn_isomorphic cycle2, parse("\x04\x08[\x06@\x00")
    assert_syn_isomorphic cycle2, parse("\x04\x08[\x06[\x06@\x00")
    refute_syn_isomorphic cycle2, parse("\x04\x08[\x06[\x06@\x06")
    refute_syn_isomorphic cycle2, parse("\x04\x08[\x06[\x06[\x06@\x06")
    refute_syn_isomorphic wrapped1_cycle1, parse("\x04\x08[\x06@\x00")
    refute_syn_isomorphic wrapped1_cycle1, parse("\x04\x08[\x06[\x06@\x00")
    assert_syn_isomorphic wrapped1_cycle1, parse("\x04\x08[\x06[\x06@\x06")
    refute_syn_isomorphic wrapped1_cycle1, parse("\x04\x08[\x06[\x06[\x06@\x06")
    refute_syn_isomorphic wrapped1_cycle2, parse("\x04\x08[\x06@\x00")
    refute_syn_isomorphic wrapped1_cycle2, parse("\x04\x08[\x06[\x06@\x00")
    refute_syn_isomorphic wrapped1_cycle2, parse("\x04\x08[\x06[\x06@\x06")
    assert_syn_isomorphic wrapped1_cycle2, parse("\x04\x08[\x06[\x06[\x06@\x06")

    non_shared = MetaArray.new([MetaArray.new([0]), MetaArray.new([0])])
    shared = MetaArray.new([MetaArray.new([0])] * 2)
    assert_syn_isomorphic non_shared, parse("\x04\x08[\x07[\x06i\x00[\x06i\x00")
    refute_syn_isomorphic non_shared, parse("\x04\x08[\x07[\x06i\x00@\x06")
    refute_syn_isomorphic shared, parse("\x04\x08[\x07[\x06i\x00[\x06i\x00")
    assert_syn_isomorphic shared, parse("\x04\x08[\x07[\x06i\x00@\x06")
  end

  def test_major_mismatch
    assert_raises(
      TypeError,
      "incompatible marshal file format (can't be read)\n" \
      "\tformat version 4.8 required; 3.8 given"
    ) do
      parse("\x03\x080")
    end
    assert_raises(
      TypeError,
      "incompatible marshal file format (can't be read)\n" \
      "\tformat version 4.8 required; 5.8 given"
    ) do
      parse("\x05\x080")
    end
  end

  def test_minor_mismatch
    assert_raises(
      TypeError,
      "incompatible marshal file format (can't be read)\n" \
      "\tformat version 4.8 required; 4.9 given"
    ) do
      parse("\x04\x090")
    end
    # TODO: check 4.7 being warned
  end

  def test_short_signature
    assert_raises(ArgumentError, 'marshal data too short') do
      parse('')
    end
    assert_raises(ArgumentError, 'marshal data too short') do
      parse("\x04")
    end
  end
end
