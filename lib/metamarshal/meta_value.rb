module Metamarshal
  module MetaValue
  end

  class MetaReference
    include MetaValue

    CLASS_MAP = {}

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

    def ===(obj)
      kind_of?(obj)
    end

    def inspect
      super.tap do |s|
        s.sub!(/\A#<Metamarshal::MetaReference/, "\#<#{self.class}")
      end
    end

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

  class MetaObject < MetaReference
    MetaReference::CLASS_MAP[:object] = self
    def self.new(klass)
      MetaReference.new(:object, klass)
    end
  end

  class MetaString < MetaReference
    MetaReference::CLASS_MAP[:string] = self
    def self.new(klass)
      MetaReference.new(:string, klass)
    end
  end

  class MetaArray < MetaReference
    MetaReference::CLASS_MAP[:array] = self
    def self.new(klass, len)
      MetaReference.new(:array, klass, Array.new(len))
    end
  end

  MetaReference::CLASS_MAP.freeze
end

class Integer
  include Metamarshal::MetaValue
end
class Float
  include Metamarshal::MetaValue
end
class Symbol
  include Metamarshal::MetaValue
end
class TrueClass
  include Metamarshal::MetaValue
end
class FalseClass
  include Metamarshal::MetaValue
end
class NilClass
  include Metamarshal::MetaValue
end
