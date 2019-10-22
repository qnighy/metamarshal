require "test_helper"

class MetaValueTest < Minitest::Test
  def test_kind_of_meta_value
    assert_kind_of Metamarshal::MetaValue, 42
    assert_kind_of Metamarshal::MetaValue, 42.0
    assert_kind_of Metamarshal::MetaValue, :foo
    assert_kind_of Metamarshal::MetaValue, true
    assert_kind_of Metamarshal::MetaValue, false
    assert_kind_of Metamarshal::MetaValue, nil
    refute_kind_of Metamarshal::MetaValue, "foo"
    refute_kind_of Metamarshal::MetaValue, [1, 2, 3]
    assert_kind_of Metamarshal::MetaValue, Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaValue, Metamarshal::MetaArray.new(nil, 10)
  end

  def test_kind_of_meta_reference
    refute_kind_of Metamarshal::MetaReference, 42
    refute_kind_of Metamarshal::MetaReference, 42.0
    refute_kind_of Metamarshal::MetaReference, :foo
    refute_kind_of Metamarshal::MetaReference, true
    refute_kind_of Metamarshal::MetaReference, false
    refute_kind_of Metamarshal::MetaReference, nil
    refute_kind_of Metamarshal::MetaReference, "foo"
    refute_kind_of Metamarshal::MetaReference, [1, 2, 3]
    assert_kind_of Metamarshal::MetaReference, Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaReference, Metamarshal::MetaArray.new(nil, 10)
  end

  def test_kind_of_meta_subclasses
    assert_kind_of Metamarshal::MetaObject, Metamarshal::MetaObject.new(nil)
    refute_kind_of Metamarshal::MetaObject, Metamarshal::MetaArray.new(nil, 10)
    refute_kind_of Metamarshal::MetaArray, Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaArray, Metamarshal::MetaArray.new(nil, 10)
  end

  def test_assign_itself
    obj = Metamarshal::MetaObject.new(nil)
    assert_kind_of Metamarshal::MetaObject, obj
    refute_kind_of Metamarshal::MetaArray, obj
    assert_equal Metamarshal::MetaObject, obj.class

    obj.itself = Metamarshal::MetaArray.new(nil, 10)
    refute_kind_of Metamarshal::MetaObject, obj
    assert_kind_of Metamarshal::MetaArray, obj
    assert_equal Metamarshal::MetaArray, obj.class
  end
end
