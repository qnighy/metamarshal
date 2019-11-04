# frozen_string_literal: true

# rubocop:disable Naming/UncommunicativeMethodParamName

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'metamarshal'

require 'minitest/autorun'

module SyntaxHelper
  include Minitest::Assertions

  # @param exp [Metamarshal::MetaValue]
  # @param act [Metamarshal::MetaValue]
  # @param msg [nil, String]
  # @return [void]
  # @raise [Minitest::Assertion]
  def assert_syn_isomorphic(exp, act, msg = nil)
    msg = message(msg, E) { diff exp, act }
    assert(syn_isomorphic(exp, act), msg)
  end

  # @param exp [Metamarshal::MetaValue]
  # @param act [Metamarshal::MetaValue]
  # @param msg [nil, String]
  # @return [void]
  # @raise [Minitest::Assertion]
  def refute_syn_isomorphic(exp, act, msg = nil)
    msg = message(msg) do
      "Expected #{mu_pp(act)} to not be equal to #{mu_pp(exp)}"
    end
    refute(syn_isomorphic(exp, act), msg)
  end

  # @param a [Metamarshal::MetaValue]
  # @param b [Metamarshal::MetaValue]
  # @param map1 [Hash{Integer=>Integer}]
  # @param map2 [Hash{Integer=>Integer}]
  # @return [Boolean]
  def syn_isomorphic(a, b, map1 = {}, map2 = {})
    return syn_value_eq(a, b) unless a.is_a?(Metamarshal::MetaReference)
    return false unless b.is_a?(Metamarshal::MetaReference)
    return map1[a.object_id] == b.object_id if map1.key? a.object_id
    return map2[b.object_id] == a.object_id if map2.key? b.object_id

    map1[a.object_id] = b.object_id
    map2[b.object_id] = a.object_id

    a.class == b.class && syn_isomorphic_ivars(a, b, map1, map2) && begin
      case a
      when Metamarshal::MetaObject then true
      when Metamarshal::MetaArray
        a.data.zip(b.data).all? do |(ai, bi)|
          syn_isomorphic(ai, bi, map1, map2)
        end
      else
        raise ArgumentError, "Unknown MetaReference: #{a.inspect}"
      end
    end
  end

  # @param a [Metamarshal::MetaValue]
  # @param b [Metamarshal::MetaReference]
  # @return [Boolean]
  def syn_value_eq(a, b)
    case a
    when NilClass, TrueClass, FalseClass, Symbol then a == b
    when Integer then b.is_a?(Integer) && a == b
    when Float then b.is_a?(Float) && a == b
    else
      raise ArgumentError, "Unknown MetaValue: #{a.inspect}"
    end
  end

  # @param a [Metamarshal::MetaReference]
  # @param b [Metamarshal::MetaReference]
  # @param map1 [Hash{Integer=>Integer}]
  # @param map2 [Hash{Integer=>Integer}]
  # @return [Boolean]
  def syn_isomorphic_ivars(a, b, map1 = {}, map2 = {})
    a.ivars.all? do |key, value|
      b.ivars.key?(key) && syn_isomorphic(value, b.ivars[key], map1, map2)
    end && b.ivars.keys.all? { |key| a.ivars.key?(key) }
  end
end

module ParserRoundTripHelper
  include Minitest::Assertions

  def assert_round_trip(bytes, msg = nil)
    assert_equal(bytes, Metamarshal.generate(Metamarshal.parse(bytes)), msg)
  end
end

module GeneratorRoundTripHelper
  include Minitest::Assertions
  include SyntaxHelper

  def assert_round_trip(node, msg = nil)
    assert_syn_isomorphic(
      node,
      Metamarshal.parse(Metamarshal.generate(node)),
      msg
    )
  end
end

# rubocop:enable Naming/UncommunicativeMethodParamName
