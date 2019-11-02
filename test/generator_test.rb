# frozen_string_literal: true

require 'test_helper'

class GeneratorTest < Minitest::Test
  include Metamarshal
  include SyntaxHelper

  def test_parse_nil
    assert_equal "\x04\x080".b, generate(nil)
  end
end
