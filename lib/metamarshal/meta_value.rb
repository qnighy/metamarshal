# frozen_string_literal: true

# rubocop:disable Naming/UncommunicativeMethodParamName

module Metamarshal
  # A node or leaf in a Metamarshal syntax graph.
  #
  # Leaf types directly inherit from MetaValue.
  #
  # Following classes are leaf types:
  #
  # - {Integer}, {Float}
  # - {Symbol}
  # - {TrueClass}, {FalseClass}
  # - {NilClass}
  #
  # Node types inherit from {MetaReference}.
  module MetaValue
  end

  # A node in a Metamarshal syntax graph.
  #
  # This class overrides {#class} and related methods to virtually treat
  # instances of MetaReference as instances of the subclasses.
  # We use this design to naturally represent node types through classes
  # while allowing modification of shared nodes' types in-place.
  #
  # The following classes inherit from MetaReference:
  #
  # - {Metamarshal::MetaObject}
  # - {Metamarshal::MetaString}
  # - {Metamarshal::MetaArray}
  #
  # @abstract Use subclasses' constructors like {Metamarshal::MetaArray.new}
  #   to generate an instance of this class.
  class MetaReference
    include MetaValue

    # A map from symbols to the class it represents.
    # used to override {#class}.
    CLASS_MAP = {} # rubocop:disable Style/MutableConstant
    private_constant :CLASS_MAP

    # Optional class name for instantiating the object.
    #
    # nil is interpreted as a default class for that type.
    #
    # @return [nil, Symbol]
    attr_reader :klass

    # Auxiliary data for non-plain objects.
    #
    # @return [Object]
    attr_reader :data

    # @param type [Symbol]
    # @param klass [nil, Symbol]
    # @param data [Object]
    def initialize(type, klass = nil, data = nil)
      @type = type
      @klass = klass
      @data = data
    end

    def initialize_copy(obj)
      self.itself = obj
    end

    # Updates itself in-place, copying from the other.
    #
    # @param other [Metamarshal::MetaReference] the other to copy from
    def itself=(other)
      @type = other.type
      @klass = other.klass
      @data = other.data.dup
    end

    # Overrides {Object#class} to allow changing types in-place.
    #
    # @return [Class]
    def class
      CLASS_MAP[type] || super
    end

    # Overrides {Object#instance_of?} to allow changing types in-place.
    #
    # @param klass [Module] a class or a module
    # @return [true, false]
    def instance_of?(klass)
      self.class == klass
    end

    # Overrides {Object#kind_of?} to allow changing types in-place.
    #
    # @param klass [Module] a class or a module
    # @return [true, false]
    def kind_of?(klass)
      super || self.class >= klass
    end

    # Overrides {Object#is_a?} to allow changing types in-place.
    #
    # @param klass [Module] a class or a module
    # @return [true, false]
    def is_a?(klass)
      super || self.class >= klass
    end

    # Overrides {Module#===} to allow changing types in-place.
    #
    # @param obj [Object] an object to check membership of
    # @return [true, false]
    def self.===(obj)
      obj.is_a?(self)
    end

    # Overrides {Object#inspect} for debug printing.
    #
    # @return [String] a debug description of this object
    def inspect
      inspect_tbl = (Thread.current[:__metamarshal_inspect_key__] ||= [])
      if inspect_tbl.include?(object_id)
        return self.class.send(:instance_inspect_cycle, self)
      end

      begin
        inspect_tbl << object_id
        self.class.send(:instance_inspect, self)
      ensure
        inspect_tbl.pop
      end
    end

    # Overrides {PPMixin#pretty_print} for debug pretty-printing.
    #
    # @param q [PP] the pretty-printer
    def pretty_print(q)
      self.class.send(:instance_pretty_print, self, q)
    end

    # Overrides {PPMixin#pretty_print_cycle} for debug pretty-printing.
    #
    # @param q [PP] the pretty-printer
    def pretty_print_cycle(q)
      self.class.send(:instance_pretty_print_cycle, self, q)
    end

    protected

    # A node type which controls {#class}.
    #
    # @return [Symbol]
    attr_reader :type

    class <<self
      private

      def instance_inspect(obj)
        'Metamarshal::MetaReference.new(' \
        "#{obj.type.inspect}, " \
        "#{obj.klass.inspect}, " \
        "#{obj.data.inspect}" \
      ')'
      end

      def instance_inspect_cycle(_obj)
        'Metamarshal::MetaReference.new(...)'
      end

      def instance_pretty_print(obj, q)
        q.group(1, 'Metamarshal::MetaReference.new(', ')') do
          q.breakable('')
          q.pp(obj.type)
          q.comma_breakable
          q.pp(obj.klass)
          q.comma_breakable
          q.pp(obj.data)
        end
      end

      def instance_pretty_print_cycle(_obj, q)
        q.text 'Metamarshal::MetaReference.new(...)'
      end
    end
  end

  # A MetaReference denoting a plain object (marshal tag: +o+)
  class MetaObject < MetaReference
    MetaReference.const_get(:CLASS_MAP)[:object] = self

    # @param klass [nil, Symbol] A class name of the object being represented
    def initialize(klass)
      # See define_method(:new) below for the actual implementation.
      super(:object, klass)
    end

    class <<self
      define_method(:new) do |klass|
        MetaReference.new(:object, klass)
      end

      private

      def instance_inspect(obj)
        "Metamarshal::MetaObject.new(#{obj.klass.inspect})"
      end

      def instance_inspect_cycle(_obj)
        'Metamarshal::MetaObject.new(...)'
      end

      def instance_pretty_print(obj, q)
        q.group(1, 'Metamarshal::MetaObject.new(', ')') do
          q.breakable('')
          q.pp(obj.klass)
        end
      end

      def instance_pretty_print_cycle(_obj, q)
        q.text 'Metamarshal::MetaObject.new(...)'
      end
    end
  end

  # A MetaReference denoting a string (marshal tag: +"+)
  class MetaString < MetaReference
    MetaReference.const_get(:CLASS_MAP)[:string] = self

    def initialize
      # See define_method(:new) below for the actual implementation.
      super(:string, nil)
    end

    class <<self
      define_method(:new) do
        MetaReference.new(:string, nil)
      end

      private

      def instance_inspect(_obj)
        'Metamarshal::MetaString.new'
      end

      def instance_inspect_cycle(_obj)
        'Metamarshal::MetaString.new(...)'
      end

      def instance_pretty_print(_obj, q)
        q.text 'Metamarshal::MetaString.new'
      end

      def instance_pretty_print_cycle(_obj, q)
        q.text 'Metamarshal::MetaString.new(...)'
      end
    end
  end

  # A MetaReference denoting an array (marshal tag: +[+)
  class MetaArray < MetaReference
    MetaReference.const_get(:CLASS_MAP)[:array] = self

    # @param elements [Array<Metamarshal::MetaValue>] A list of elements.
    def initialize(elements)
      # See define_method(:new) below for the actual implementation.
      super(:array, nil, elements)
    end

    class <<self
      define_method(:new) do |elements|
        MetaReference.new(:array, nil, elements)
      end

      private

      def instance_inspect(obj)
        "Metamarshal::MetaArray.new(#{obj.data.inspect})"
      end

      def instance_inspect_cycle(_obj)
        'Metamarshal::MetaArray.new(...)'
      end

      def instance_pretty_print(obj, q)
        q.group(1, 'Metamarshal::MetaArray.new(', ')') do
          q.breakable('')
          q.pp(obj.data)
        end
      end

      def instance_pretty_print_cycle(_obj, q)
        q.text 'Metamarshal::MetaArray.new(...)'
      end
    end
  end
end

Metamarshal::MetaReference.const_get(:CLASS_MAP).freeze

# The built-in integer type.
#
# This class inherits {Metamarshal::MetaValue},
# meaning that the class can be a part of syntax graph.
#
# @example Generate a marshal binary
#   Metamarshal.generate(42)
#   # => "\x04\bi/"
class Integer
  include Metamarshal::MetaValue
end

# The built-in floating-point type.
#
# This class inherits {Metamarshal::MetaValue},
# meaning that the class can be a part of syntax graph.
#
# @example Generate a marshal binary
#   Metamarshal.generate(42.0)
#   # => "\x04\bf\a42"
class Float
  include Metamarshal::MetaValue
end

# The built-in symbol type.
#
# This class inherits {Metamarshal::MetaValue},
# meaning that the class can be a part of syntax graph.
#
# @example Generate a marshal binary
#   Metamarshal.generate(:foo)
#   # => "\x04\b:\bfoo"
class Symbol
  include Metamarshal::MetaValue
end

# The built-in type for true.
#
# This class inherits {Metamarshal::MetaValue},
# meaning that the class can be a part of syntax graph.
#
# @example Generate a marshal binary
#   Metamarshal.generate(true)
#   # => "\x04\bT"
class TrueClass
  include Metamarshal::MetaValue
end

# The built-in type for false.
#
# This class inherits {Metamarshal::MetaValue},
# meaning that the class can be a part of syntax graph.
#
# @example Generate a marshal binary
#   Metamarshal.generate(false)
#   # => "\x04\bF"
class FalseClass
  include Metamarshal::MetaValue
end

# The built-in type for nil.
#
# This class inherits {Metamarshal::MetaValue},
# meaning that the class can be a part of syntax graph.
#
# @example Generate a marshal binary
#   Metamarshal.generate(nil)
#   # => "\x04\b0"
class NilClass
  include Metamarshal::MetaValue
end

# rubocop:enable Naming/UncommunicativeMethodParamName
