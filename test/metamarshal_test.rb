require "test_helper"

class MetamarshalTest < Minitest::Test
  include SyntaxHelper

  def test_that_it_has_a_version_number
    refute_nil ::Metamarshal::VERSION
  end
end
