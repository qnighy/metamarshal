# frozen_string_literal: true

module Metamarshal # rubocop:disable Style/Documentation
  # A value which can be used as a node in a Marshal syntax graph node.
  module MetaValue
  end

  # A MetaValue that is distinguished by its address.
  class MetaReference
    include MetaValue

    # rubocop:disable Style/MutableConstant
    CLASS_MAP = {}
    # rubocop:enable Style/MutableConstant

    attr_reader :type, :klass, :data

    def initialize(type, klass = nil, data = nil)
      @type = type
      @klass = klass
      @data = data
    end

    def itself=(other)
      @type = other.type
      @klass = other.klass
      @data = other.data.dup
    end

    def class
      CLASS_MAP[type] || super
    end

    def instance_of?(klass)
      self.class == klass
    end

    def kind_of?(klass)
      super || self.class >= klass
    end
    alias is_a? kind_of?

    def self.===(obj)
      obj.is_a?(self)
    end

    def inspect
      inspect_tbl = (Thread.current[:__metamarshal_inspect_key__] ||= [])
      if inspect_tbl.include?(object_id)
        return self.class.instance_inspect_cycle(self)
      end

      begin
        inspect_tbl << object_id
        self.class.instance_inspect(self)
      ensure
        inspect_tbl.pop
      end
    end

    # :nodoc:
    def self.instance_inspect(obj)
      'Metamarshal::MetaReference.new(' \
        "#{obj.type.inspect}, " \
        "#{obj.klass.inspect}, " \
        "#{obj.data.inspect}" \
      ')'
    end

    # :nodoc:
    def self.instance_inspect_cycle(_obj)
      'Metamarshal::MetaReference.new(...)'
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName
    def pretty_print(q)
      self.class.instance_pretty_print(self, q)
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    # rubocop:disable Naming/UncommunicativeMethodParamName
    def pretty_print_cycle(q)
      self.class.instance_pretty_print_cycle(self, q)
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print(obj, q)
      q.group(1, 'Metamarshal::MetaReference.new(', ')') do
        q.breakable('')
        q.pp(obj.type)
        q.comma_breakable
        q.pp(obj.klass)
        q.comma_breakable
        q.pp(obj.data)
      end
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print_cycle(_obj, q)
      q.text 'Metamarshal::MetaReference.new(...)'
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    def clone(*)
      super.tap do |v|
        v.instance_variable_set(:@data, v.instance_variable_get(:@data).dup)
      end
    end

    def dup
      super.tap do |v|
        v.instance_variable_set(:@data, v.instance_variable_get(:@data).dup)
      end
    end
  end

  # A MetaReference denoting a plain object (marshal tag: +o+)
  class MetaObject < MetaReference
    MetaReference::CLASS_MAP[:object] = self
    def self.new(klass)
      MetaReference.new(:object, klass)
    end

    # :nodoc:
    def self.instance_inspect(obj)
      "Metamarshal::MetaObject.new(#{obj.klass.inspect})"
    end

    # :nodoc:
    def self.instance_inspect_cycle(_obj)
      'Metamarshal::MetaObject.new(...)'
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print(obj, q)
      q.group(1, 'Metamarshal::MetaObject.new(', ')') do
        q.breakable('')
        q.pp(obj.klass)
      end
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print_cycle(_obj, q)
      q.text 'Metamarshal::MetaObject.new(...)'
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName
  end

  # A MetaReference denoting a string (marshal tag: +"+)
  class MetaString < MetaReference
    MetaReference::CLASS_MAP[:string] = self
    def self.new
      MetaReference.new(:string, nil)
    end

    # :nodoc:
    def self.instance_inspect(_obj)
      'Metamarshal::MetaString.new'
    end

    # :nodoc:
    def self.instance_inspect_cycle(_obj)
      'Metamarshal::MetaString.new(...)'
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print(_obj, q)
      q.text 'Metamarshal::MetaString.new'
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print_cycle(_obj, q)
      q.text 'Metamarshal::MetaString.new(...)'
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName
  end

  # A MetaReference denoting an array (marshal tag: +[+)
  class MetaArray < MetaReference
    MetaReference::CLASS_MAP[:array] = self
    def self.new(elements)
      MetaReference.new(:array, nil, elements)
    end

    # :nodoc:
    def self.instance_inspect(obj)
      "Metamarshal::MetaArray.new(#{obj.data.inspect})"
    end

    # :nodoc:
    def self.instance_inspect_cycle(_obj)
      'Metamarshal::MetaArray.new(...)'
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print(obj, q)
      q.group(1, 'Metamarshal::MetaArray.new(', ')') do
        q.breakable('')
        q.pp(obj.data)
      end
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    # rubocop:disable Naming/UncommunicativeMethodParamName
    # :nodoc:
    def self.instance_pretty_print_cycle(_obj, q)
      q.text 'Metamarshal::MetaArray.new(...)'
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName
  end

  MetaReference::CLASS_MAP.freeze
end

# :nodoc:
class Integer
  include Metamarshal::MetaValue
end
# :nodoc:
class Float
  include Metamarshal::MetaValue
end
# :nodoc:
class Symbol
  include Metamarshal::MetaValue
end
# :nodoc:
class TrueClass
  include Metamarshal::MetaValue
end
# :nodoc:
class FalseClass
  include Metamarshal::MetaValue
end
# :nodoc:
class NilClass
  include Metamarshal::MetaValue
end
