module Metamarshal
  class Parser
    def initialize(port)
      if port.respond_to?(:to_str)
        @src = port.to_str
        @src.force_encoding(Encoding::ASCII_8BIT)
        @offset = 0
      elsif port.respond_to?(:getbyte) && port.respond_to?(:read)
        port.try(:binmode, 0, 0)
        @src = port
        @buf = "\0" * 1024
        @buf.force_encoding(Encoding::ASCII_8BIT)
        @readable = 0
        @buflen = 0
      else
        raise TypeError, "instance of IO needed"
      end
    end

    def parse
      major = r_byte
      minor = r_byte
      if major != MAJOR_VERSION || minor > MINOR_VERSION
        raise TypeError, "incompatible marshal file format (can't be read)\n\tformat version #{MAJOR_VERSION}.#{MINOR_VERSION} required; #{major}.#{minor} given"
      end
      if minor != MINOR_VERSION
        warn "incompatible marshal file format (can be read)\n\tformat version #{MAJOR_VERSION}.#{MINOR_VERSION} required; #{major}.#{minor} given"
      end
      r_object
    end

    private

    def too_short
      raise ArgumentError, "marshal data too short"
    end

    def r_byte1_buffered
      if @buflen == 0
        bufsiz = @buf.size
        readable = @readable < bufsiz ? @readable : bufsiz
        str = @src.read(1, @buf)
        too_short if str.nil?
        @offset = 0
        @buflen = str.size
      end
      @buflen -= 1
      c = @buf.getbyte(@offset)
      @offset += 1
      c
    end

    def r_byte
      if @offset
        too_short unless @offset < @src.size
        c = @src.getbyte(@offset)
        @offset += 1
        c
      else
        if @readable > 0 || @buflen > 0
          r_byte1_buffered
        else
          @src.getbyte
        end
      end
    end

    def r_long
      c = r_byte
      c -= 256 if c >= 128
      return 0 if c == 0
      if c > 0
        return c - 5 if 4 < c && c < 128
        x = 0
        c.times do |i|
          x |= r_byte << (8*i)
        end
        x
      else
        return c + 5 if -129 < c && c < -4
        c = -c
        x = -1 << (8*c)
        c.times do |i|
          x |= r_byte << (8*i)
        end
        x
      end
    end

    def r_object
      type = r_byte
      case type
      when 0x30  # '0', TYPE_NIL
        nil
      when 0x54  # 'T', TYPE_TRUE
        true
      when 0x46  # 'F', TYPE_FALSE
        false
      when 0x69  # 'i', TYPE_FIXNUM
        r_long
      else
        raise ArgumentError, "dump format error(0x%x)" % type
      end
    end
  end
end