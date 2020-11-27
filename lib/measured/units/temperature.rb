# frozen_string_literal: true
Measured::Temperature = Measured.build do
  unit :C, aliases: [:tempC, :celsius], base_offset: 0

  unit :F, value: "5/9 C", aliases: [:tempF, :fahrenheit], base_offset: 32
  unit :J, value: "7/16 C", base_offset: -54
end
