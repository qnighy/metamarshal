# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

require 'test_helper'
require 'pp'

class MetaValueTest < Minitest::Test
  def test_kind_of_meta_value
    assert_kind_of Metamarshal::MetaValue, 42
    assert_kind_of Metamarshal::MetaValue, 42.0
    assert_kind_of Metamarshal::MetaValue, :foo
    assert_kind_of Metamarshal::MetaValue, true
    assert_kind_of Metamarshal::MetaValue, false
    assert_kind_of Metamarshal::MetaValue, nil
    refute_kind_of Metamarshal::MetaValue, 'foo'
    refute_kind_of Metamarshal::MetaValue, [1, 2, 3]
    assert_kind_of Metamarshal::MetaValue, Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaValue, Metamarshal::MetaArray.new([])
  end

  def test_kind_of_meta_reference
    refute_kind_of Metamarshal::MetaReference, 42
    refute_kind_of Metamarshal::MetaReference, 42.0
    refute_kind_of Metamarshal::MetaReference, :foo
    refute_kind_of Metamarshal::MetaReference, true
    refute_kind_of Metamarshal::MetaReference, false
    refute_kind_of Metamarshal::MetaReference, nil
    refute_kind_of Metamarshal::MetaReference, 'foo'
    refute_kind_of Metamarshal::MetaReference, [1, 2, 3]
    assert_kind_of Metamarshal::MetaReference, Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaReference, Metamarshal::MetaArray.new([])
  end

  def test_kind_of_meta_subclasses
    assert_kind_of Metamarshal::MetaObject, Metamarshal::MetaObject.new(nil)
    refute_kind_of Metamarshal::MetaObject, Metamarshal::MetaArray.new([])
    refute_kind_of Metamarshal::MetaArray, Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaArray, Metamarshal::MetaArray.new([])
  end

  def test_assign_itself
    obj = Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaObject, obj
    refute_kind_of Metamarshal::MetaArray, obj
    assert_equal Metamarshal::MetaObject, obj.class

    obj.itself = Metamarshal::MetaArray.new([])
    refute_kind_of Metamarshal::MetaObject, obj
    assert_kind_of Metamarshal::MetaArray, obj
    assert_equal Metamarshal::MetaArray, obj.class
  end

  def test_inspect
    assert_equal(
      Metamarshal::MetaArray.new([1, 2, 3]).inspect,
      'Metamarshal::MetaArray.new([1, 2, 3])'
    )

    cycle1 = Metamarshal::MetaArray.new([]).tap do |a|
      a.data << a
    end
    assert_equal(
      cycle1.inspect,
      'Metamarshal::MetaArray.new([Metamarshal::MetaArray.new(...)])'
    )
  end

  def test_pretty_print
    assert_equal(
      PP.pp(Metamarshal::MetaArray.new([1, 2, 3]), +'', 79),
      "Metamarshal::MetaArray.new([1, 2, 3])\n"
    )
    assert_equal(
      PP.pp(Metamarshal::MetaArray.new([1, 2, 3]), +'', 30),
      "Metamarshal::MetaArray.new(\n" \
      " [1, 2, 3])\n"
    )

    cycle1 = Metamarshal::MetaArray.new([]).tap do |a|
      a.data << a
    end
    assert_equal(
      PP.pp(cycle1, +'', 79),
      "Metamarshal::MetaArray.new([Metamarshal::MetaArray.new(...)])\n"
    )
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
