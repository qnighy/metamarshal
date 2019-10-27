# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'metamarshal'

require 'minitest/autorun'

module SyntaxHelper
  include Minitest::Assertions

  def assert_syn_isomorphic(exp, act, msg = nil)
    msg = message(msg, E) { diff exp, act }
    assert(syn_isomorphic(exp, act), msg)
  end

  def refute_syn_isomorphic(exp, act, msg = nil)
    msg = message(msg) do
      "Expected #{mu_pp(act)} to not be equal to #{mu_pp(exp)}"
    end
    refute(syn_isomorphic(exp, act), msg)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Naming/UncommunicativeMethodParamName
  def syn_isomorphic(a, b, map1 = {}, map2 = {})
    return map1[a.object_id] == b.object_id if map1.key? a.object_id
    return map2[b.object_id] == a.object_id if map2.key? b.object_id

    map1[a.object_id] = b.object_id
    map2[b.object_id] = a.object_id
    case a
    when NilClass, TrueClass, FalseClass, Symbol then a == b
    when Integer then b.is_a?(Integer) && a == b
    when Float then b.is_a?(Float) && a == b
    when Metamarshal::MetaArray
      b.is_a?(Metamarshal::MetaArray) && begin
        a.klass == b.klass && a.data.size == b.data.size && begin
          a.data.zip(b.data).all? do |(ai, bi)|
            syn_isomorphic(ai, bi, map1, map2)
          end
        end
      end
    else
      raise ArgumentError, "Unknown MetaValue: #{a.inspect}"
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Naming/UncommunicativeMethodParamName
end
