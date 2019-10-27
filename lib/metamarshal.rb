# frozen_string_literal: true

require 'metamarshal/version'
require 'metamarshal/meta_value'
require 'metamarshal/parser'

# Pure Ruby Marshal.
module Metamarshal
  MAJOR_VERSION = 4
  MINOR_VERSION = 8

  module_function

  def parse(port)
    parser = Metamarshal::Parser.new(port)
    parser.parse
  end
end
