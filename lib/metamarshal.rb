# frozen_string_literal: true

require 'metamarshal/version'
require 'metamarshal/meta_value'
require 'metamarshal/parser'
require 'metamarshal/generator'

# Pure Ruby Marshal.
module Metamarshal
  MAJOR_VERSION = 4
  MINOR_VERSION = 8

  module_function

  def parse(port)
    parser = Metamarshal::Parser.new(port)
    parser.parse
  end

  def generate(node, port = nil, limit = nil)
    if port && !limit
      limit = port
      port = nil
    end
    limit ||= -1

    generator = Metamarshal::Generator.new(port)
    generator.generate(node, limit)
  end
end
