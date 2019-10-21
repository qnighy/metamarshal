module Metamarshal
  module MetaValue
  end

  class MetaReference
    include MetaValue

    def initialize(type, klass)
      @type = type
      @klass = klass if klass
    end
  end

  class MetaObject < MetaReference
    def self.new(klass)
      MetaReference.new(:object, klass)
    end
  end

  class MetaString < MetaReference
    def self.new(klass)
      MetaReference.new(:string, klass)
    end
  end

  class MetaArray < MetaReference
    def self.new(klass)
      MetaReference.new(:array, klass)
    end
  end
end

class Integer
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
