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
      self.class.instance_inspect(self)
    end

    # :nodoc:
    def self.instance_inspect(obj)
      'Metamarshal::MetaReference.new(' \
        "#{obj.type.inspect}, " \
        "#{obj.klass.inspect}, " \
        "#{obj.data.inspect}" \
      ')'
    end

    # rubocop:disable Layout/SpaceInsideBlockBraces
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Naming/UncommunicativeMethodParamName
    # rubocop:disable Style/BlockDelimiters
    # rubocop:disable Style/CaseEquality
    # rubocop:disable Style/Lambda
    def pretty_print(q)
      str = Kernel.instance_method(:to_s).bind(self).call
      str.chomp!('>')
      str.sub!(/\A#<Metamarshal::MetaReference/, "\#<#{self.class}")
      q.group(1, str, '>') {
        q.seplist(pretty_print_instance_variables, lambda { q.text ',' }) {|v|
          q.breakable
          v = v.to_s if Symbol === v
          q.text v
          q.text '='
          q.group(1) {
            q.breakable ''
            q.pp(instance_eval(v))
          }
        }
      }
    end
    # rubocop:enable Layout/SpaceInsideBlockBraces
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Naming/UncommunicativeMethodParamName
    # rubocop:enable Style/BlockDelimiters
    # rubocop:enable Style/CaseEquality
    # rubocop:enable Style/Lambda

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
