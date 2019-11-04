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

  def test_symbol
    assert_round_trip :""
    assert_round_trip :foo
  end

  def test_symlink
    assert_round_trip MetaArray.new(%i[foo bar bar foo])
  end

  def test_object
    assert_round_trip(
      MetaObject.new(
        :Range,
        {
          excl: false,
          begin: 1,
          end: 2
        }
      )
    )

    assert_round_trip(
      MetaObject.new(
        :Matrix,
        {
          "@rows": MetaArray.new(
            [MetaArray.new([1, 2]), MetaArray.new([3, 4])]
          ),
          "@column_count": 2
        }
      )
    )
  end

  def test_array
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
