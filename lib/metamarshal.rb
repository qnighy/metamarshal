# frozen_string_literal: true

require 'metamarshal/version'
require 'metamarshal/meta_value'
require 'metamarshal/parser'
require 'metamarshal/generator'

# Pure Ruby Marshal.
#
# @example Parse a marshal data into a syntax graph
#   Metamarshal.parse("\x04\x08[\x08i\x00i\x06i\x07".b)
#   # => Metamarshal::MetaArray.new([0, 1, 2])
#
# @example Generate a marshal data from a syntax graph
#   Metamarshal.generate(Metamarshal::MetaArray.new([0, 1, 2]))
#   # =>  "\x04\b[\bi\x00i\x06i\a"
#
module Metamarshal
  # Major version of the marshal format.
  #
  # {.generate} generates the marshal data of this version.
  #
  # {.parse} can only parse the marshal data of this version.
  MAJOR_VERSION = 4

  # Minor version of the marshal format.
  #
  # {.generate} generates the marshal data of this version.
  #
  # {.parse} can only parse the marshal data of this version or below.
  MINOR_VERSION = 8

  private_constant :Parser, :Generator

  module_function

  # Parses a marshal data into a syntax graph.
  #
  # @param source [String, IO, #read] from which the parser reads
  # @return [Metamarshal::MetaValue] a parsed syntax graph
  def parse(source)
    parser = Parser.new(source)
    parser.parse
  end

  # Generates a marshal data from a syntax graph.
  #
  # @overload generate(node, anIO, limit = -1)
  #   Writes a generated marshal data to a given instance of IO.
  #   @param node [Metamarshal::MetaValue] a node of a syntax graph
  #   @param anIO [IO, #write] into which the generator writes
  #   @param limit [Integer] recursion limit. Negative value means no limits.
  #   @return [IO, #write] same as anIO
  # @overload generate(node, limit = -1)
  #   Writes a generated marshal data to a buffer and returns it.
  #   @param node [Metamarshal::MetaValue] a node of a syntax graph
  #   @param limit [Integer] recursion limit. Negative value means no limits.
  #   @return [String] marshalled binary data
  def generate(node, port = nil, limit = nil)
    if port && !limit
      limit = port
      port = nil
    end
    limit ||= -1

    generator = Generator.new(port)
    generator.generate(node, limit)
  end
end
