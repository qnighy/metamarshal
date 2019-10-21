require "metamarshal/version"
require "metamarshal/meta_value"
require "metamarshal/parser"

module Metamarshal
  MAJOR_VERSION = 4
  MINOR_VERSION = 8

  def parse(port)
    parser = Metamarshal::Parser.new(port)
    parser.parse
  end

  module_function :parse
end
