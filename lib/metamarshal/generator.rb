# frozen_string_literal: true

# rubocop:disable Style/NumericPredicate

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

    # @param node [Metamarshal::MetaValue]
    # @param limit [Integer]
    # @return [void]
    def w_object(node, limit)
      raise ArgumentError, 'exceed depth limit' if limit == 0
      if @data.key?(node.object_id) # rubocop:disable Style/IfUnlessModifier
        raise 'TODO'
      end

      if node.nil?
        w_byte 0x30 # '0', TYPE_NIL
      elsif node == true
        w_byte 0x54 # 'T', TYPE_TRUE
      elsif node == false
        w_byte 0x46 # 'F', TYPE_FALSE
      else
        raise "TODO: #{node.class}"
      end
    end
  end
end

# rubocop:enable Style/NumericPredicate
