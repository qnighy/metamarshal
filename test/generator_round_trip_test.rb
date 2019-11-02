# frozen_string_literal: true

require 'test_helper'

class GeneratorRoundTripTest < Minitest::Test
  include GeneratorRoundTripHelper
  include Metamarshal

  def test_nil
    assert_round_trip nil
  end

  def test_true
    assert_round_trip true
  end

  def test_false
    assert_round_trip false
  end

  def test_fixnum
    (-300..300).each do |x|
      assert_round_trip x
    end

    300.times do
      assert_round_trip rand(-0x10000...0x10000)
    end

    300.times do
      assert_round_trip rand(-0x1000000...0x1000000)
    end

    300.times do
      assert_round_trip rand(-0x40000000...0x40000000)
    end
  end

  def test_parse_array
    assert_round_trip MetaArray.new([])
    assert_round_trip MetaArray.new([1])
    assert_round_trip MetaArray.new([1, 2])
    assert_round_trip MetaArray.new([1, 2, 3])
    10.times do
      a = MetaArray.new(Array.new(rand(300)) { rand(-300..300) })
      assert_round_trip a
    end
  end
end