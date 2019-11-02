# frozen_string_literal: true

# rubocop:disable Style/NumericPredicate
# rubocop:disable Style/YodaCondition

module Metamarshal
  # An internal class to implement {Marshal.generate}.
  class Generator
    # @param port [nil, IO, #write]
    def initialize(port)
      @dest = port
      @data = {}
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

    # @param c [Integer] a byte to write
    # @return [void]
    def w_byte(c) # rubocop:disable Naming/UncommunicativeMethodParamName
      if @dest # rubocop:disable Style/GuardClause
        raise 'TODO'
      else
        @buf << c.chr
      end
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

    # @param node [Metamarshal::MetaValue]
    # @param limit [Integer]
    # @return [void]
    def w_object(node, limit)
      raise ArgumentError, 'exceed depth limit' if limit == 0

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
      elsif node.is_a?(Metamarshal::MetaArray)
        @data[node.object_id] = @data.size
        w_byte 0x5B # '[', TYPE_ARRAY
        w_long node.data.size
        node.data.each do |element|
          w_object(element, limit - 1)
        end
      else
        raise "TODO: #{node.class}"
      end
    end
  end
end

# rubocop:enable Style/NumericPredicate
# rubocop:enable Style/YodaCondition
