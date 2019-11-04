# frozen_string_literal: true

# rubocop:disable Style/NumericPredicate
# rubocop:disable Style/YodaCondition

module Metamarshal
  # rubocop:disable Metrics/ClassLength

  # An internal class to implement {Marshal.generate}.
  class Generator
    # rubocop:enable Metrics/ClassLength

    # @param port [nil, IO, #write]
    def initialize(port)
      @dest = port
      @data = {}
      @symbols = {}
      @buf = +''.b
    end

    # @param node [Metamarshal::MetaValue]
    # @param limit [Integer]
    # @return [String, IO, #write]
    def generate(node, limit)
      w_byte MAJOR_VERSION
      w_byte MINOR_VERSION
      w_object(node, limit)
      if @dest # rubocop:disable Style/RedundantCondition
        @dest
      else
        @buf
      end
    end

    private

    # @param s [String]
    # @return [void]
    def w_nbyte(s) # rubocop:disable Naming/UncommunicativeMethodParamName
      if @dest # rubocop:disable Style/GuardClause
        raise 'TODO'
      else
        @buf << s
      end
    end

    # @param c [Integer] a byte to write
    # @return [void]
    def w_byte(c) # rubocop:disable Naming/UncommunicativeMethodParamName
      w_nbyte c.chr
    end

    # @param s [String]
    # @return [void]
    def w_bytes(s) # rubocop:disable Naming/UncommunicativeMethodParamName
      w_long s.bytesize
      w_nbyte s
    end

    # @param x [Integer]
    # @return [void]
    def w_long(x) # rubocop:disable Naming/UncommunicativeMethodParamName
      unless -0x100000000 <= x && x < 0x100000000
        raise TypeError, 'long too big to dump'
      end

      return w_byte(0) if x == 0
      return w_byte(x + 5) if 0 < x && x < 123
      return w_byte((x - 5) & 0xFF) if -124 < x && x < 0

      c = (x.bit_length + 7) / 8
      w_byte(x > 0 ? c : 0x100 - c)
      c.times do |i|
        w_byte((x >> (8 * i)) & 0xFF)
      end
    end

    # @param sym [Symbol]
    # @return [void]
    def w_symbol(sym)
      if @symbols.key?(sym)
        w_byte 0x3B # ';', TYPE_SYMLINK
        w_long @symbols[sym]
      else
        @symbols[sym] = @symbols.size
        str = sym.to_s
        unless str.encoding.ascii_compatible? && str.ascii_only?
          raise 'TODO: encoding'
        end

        w_byte 0x3A # ':', TYPE_SYMBOL
        w_bytes str
      end
    end

    # @param sym [Symbol]
    # @return [void]
    def w_unique(sym)
      # TODO: check must_not_be_anonymous
      w_symbol(sym)
    end

    # @param obj [Metamarshal::MetaReference]
    # @param limit [Integer]
    # @return [void]
    def w_objivar(obj, limit)
      w_long obj.ivars.size
      obj.ivars.each do |key, value|
        w_symbol key
        w_object value, limit
      end
    end

    # @param node [Metamarshal::MetaValue]
    # @param limit [Integer]
    # @return [void]
    def w_object(node, limit)
      raise ArgumentError, 'exceed depth limit' if limit == 0

      limit -= 1 if limit > 0

      if @data.key?(node.object_id)
        w_byte 0x40 # '@', TYPE_LINK
        w_long @data[node.object_id]
        return
      end

      if node.nil?
        w_byte 0x30 # '0', TYPE_NIL
      elsif node == true
        w_byte 0x54 # 'T', TYPE_TRUE
      elsif node == false
        w_byte 0x46 # 'F', TYPE_FALSE
      elsif node.is_a?(Integer)
        if -0x40000000 <= node && node < 0x40000000 # rubocop:disable Style/GuardClause
          w_byte 0x69 # 'i', TYPE_FIXNUM
          w_long node
        else
          raise 'TODO: bigint'
        end
      elsif node.is_a?(Symbol)
        w_symbol(node)
      elsif node.is_a?(Float)
        raise 'TODO: Float'
      elsif node.is_a?(Metamarshal::MetaObject)
        @data[node.object_id] = @data.size
        w_byte 0x6F # 'o', TYPE_OBJECT
        w_unique node.klass
        w_objivar node, limit
      elsif node.is_a?(Metamarshal::MetaArray)
        @data[node.object_id] = @data.size
        w_byte 0x5B # '[', TYPE_ARRAY
        w_long node.data.size
        node.data.each do |element|
          w_object(element, limit)
        end
      else
        raise "TODO: #{node.class}"
      end
    end
  end
end

# rubocop:enable Style/NumericPredicate
# rubocop:enable Style/YodaCondition
