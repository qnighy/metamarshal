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
end
