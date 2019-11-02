# frozen_string_literal: true

# rubocop:disable Style/NumericPredicate

module Metamarshal
  # :nodoc:
  class Generator
    def initialize(port)
      @dest = port
      @data = {}
      @buf = +''.b
    end

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

    def w_byte(c) # rubocop:disable Naming/UncommunicativeMethodParamName
      if @dest # rubocop:disable Style/GuardClause
        raise 'TODO'
      else
        @buf << c.chr
      end
    end

    def w_object(node, limit)
      raise ArgumentError, 'exceed depth limit' if limit == 0
      if @data.key?(node.object_id) # rubocop:disable Style/IfUnlessModifier
        raise 'TODO'
      end

      if node.nil? # rubocop:disable Style/GuardClause
        w_byte 0x30 # '0', TYPE_NIL
      else
        raise "TODO: #{node.class}"
      end
    end
  end
end

# rubocop:enable Style/NumericPredicate
