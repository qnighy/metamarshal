# frozen_string_literal: true

require 'test_helper'

class ParserRoundTripTest < Minitest::Test
  include ParserRoundTripHelper

  def test_nil
    assert_round_trip "\x04\x080"
  end

  def test_true
    assert_round_trip "\x04\x08T"
  end

  def test_false
    assert_round_trip "\x04\x08F"
  end

  def test_fixnum_short
    (0..255).each do |b|
      next if (251..255).cover?(b) || (1..5).cover?(b)

      assert_round_trip "\x04\x08i#{b.chr}"
    end
  end

  def test_fixnum_long
    (-0xFF..0xFF).each do |x|
      next if (-123..122).cover?(x)

      c = x.positive? ? 1 : 0xFF
      assert_round_trip "\x04\x08i#{c.chr}#{(x & 0xFF).chr}"
    end

    300.times do
      x = rand(-0x10000...0x10000)
      redo if (-0x100...0x100).cover?(x)

      c = x.positive? ? 2 : 0xFE
      assert_round_trip "\x04\x08i#{c.chr}#{[x & 0xFFFF].pack('S<')}"
    end

    300.times do
      x = rand(-0x1000000...0x1000000)
      redo if (-0x10000...0x10000).cover?(x)

      c = x.positive? ? 3 : 0xFD
      assert_round_trip "\x04\x08i#{c.chr}#{[x & 0xFFFFFF].pack('L<')[0..2]}"
    end

    300.times do
      x = rand(-0x40000000..0x40000000)
      redo if (-0x1000000..0x1000000).cover?(x)

      c = x.positive? ? 4 : 0xFC
      assert_round_trip "\x04\x08i#{c.chr}#{[x & 0xFFFFFFFF].pack('L<')}"
    end
  end

  def test_symbol
    assert_round_trip "\x04\x08:\x00".b
    assert_round_trip "\x04\x08:\x06f".b
    assert_round_trip "\x04\x08:\x08foo".b
  end

  def test_symlink
    assert_round_trip "\x04\x08[\x09:\x08foo:\x08bar;\x06;\x00".b
  end

  def test_object
    assert_round_trip(
      "\x04\x08o:\x0ARange\x08:\texclF:\x0Abegini\x06:\x08endi\x07".b
    )

    assert_round_trip(
      "\x04\x08o:\x0BMatrix\x07" \
      ":\x0A@rows[\x07[\x07i\x06i\x07[\x07i\x08i\x09" \
      ":\x12@column_counti\x07".b
    )
  end

  def test_array
    assert_round_trip "\x04\x08[\x00"
    assert_round_trip "\x04\x08[\x06i\x06"
    assert_round_trip "\x04\x08[\x07i\x06i\x07"
    assert_round_trip "\x04\x08[\x08i\x06i\x07i\x08"
    assert_round_trip "\x04\x08[\x01\x96#{'0' * 150}".b
  end
end
