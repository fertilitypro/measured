# frozen_string_literal: true
class Measured::Unit
  include Comparable

  attr_reader :name, :names, :aliases, :conversion_amount, :conversion_unit, :unit_system, :inverse_conversion_amount,
              :base_offset

  def initialize(name, aliases: [], value: nil, unit_system: nil, base_offset: 0)
    @name = name.to_s.freeze
    @aliases = aliases.map(&:to_s).map(&:freeze).freeze
    @names = ([@name] + @aliases).sort!.freeze
    @conversion_amount, @conversion_unit = parse_value(value) if value
    @inverse_conversion_amount = (1 / conversion_amount if conversion_amount)
    @conversion_string = ("#{conversion_amount} #{conversion_unit}" if conversion_amount || conversion_unit)
    @unit_system = unit_system
    @base_offset = base_offset
  end

  def with(name: nil, unit_system: nil, aliases: nil, value: nil, base_offset: nil)
    self.class.new(
      name || self.name,
      aliases: aliases || self.aliases,
      value: value || @conversion_string,
      unit_system: unit_system || self.unit_system,
      base_offset: base_offset || self.base_offset
    )
  end

  def to_s
    if @conversion_string
      "#{name} (#{@conversion_string})".freeze
    else
      name
    end
  end

  def inspect
    pieces = [name]
    pieces << "(#{aliases.join(", ")})" if aliases.any?
    pieces << @conversion_string if @conversion_string
    "#<#{self.class.name}: #{pieces.join(" ")}>".freeze
  end

  def <=>(other)
    if self.class == other.class
      names_comparison = names <=> other.names
      if names_comparison != 0
        names_comparison
      else
        conversion_amount <=> other.conversion_amount
      end
    else
      name <=> other
    end
  end

  private

  def parse_value(tokens)
    case tokens
    when String
      tokens = Measured::Parser.parse_string(tokens)
    when Array
      raise Measured::UnitError, "Cannot parse [number, unit] formatted tokens from #{tokens}." unless tokens.size == 2
    else
      raise Measured::UnitError, "Unit must be defined as string or array, but received #{tokens}"
    end

    [tokens[0].to_r, tokens[1].freeze]
  end
end
