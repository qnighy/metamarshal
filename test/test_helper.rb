$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "metamarshal"

require "minitest/autorun"

module SyntaxHelper
  include Minitest::Assertions

  def assert_syn_isomorphic(exp, act, msg = nil)
    msg = message(msg, E) { diff exp, act }
    assert(syn_isomorphic(exp, act), msg)
  end

  def syn_isomorphic(a, b, map1 = {}, map2 = {})
    return map1[a.object_id] == b.object_id if map1.has_key? a.object_id
    return map2[b.object_id] == a.object_id if map2.has_key? b.object_id
    map1[a.object_id] = b.object_id
    map2[b.object_id] = a.object_id
    case a
    when NilClass, TrueClass, FalseClass, Symbol; a == b
    when Integer; Integer === b && a == b
    when Float; Float === b && a == b
    when Metamarshal::MetaArray
      Metamarshal::MetaArray === b && begin
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
end
