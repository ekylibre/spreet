# encoding: UTF-8
module Spreet

  # This class permit to manipulate coordinates in a table
  class Coordinates
    # Limit coordinates x and y in 0..65535 but coordinates are in one integer of 32 bits
    X_BIT_SHIFT = 20 # ((RUBY_PLATFORM.match(/^[^\-]*[^\-0-9]64/) ? 64 : 32) / 2).freeze
    # 2²⁰ rows = 1_048_576,  2¹² cols = 4_096,
    Y_FILTER = ((1 << X_BIT_SHIFT) - 1).freeze

    BASE_26_BEF = "0123456789abcdefghijklmnop"
    BASE_26_AFT = "abcdefghijklmnopqrstuvwxyz"

    attr_accessor :x, :y
    def initialize(*args)
      value = (args.size == 1 ? args[0] : args)
      @x, @y = 0, 0
      if value.is_a? String
        if value.downcase.match(/^[a-z]+[0-9]+$/)
          value = value.downcase.split(/([A-Z]+|[0-9]+)/).delete_if{|x| x.size.zero?}
          @x, @y = value[0].tr(BASE_26_AFT, BASE_26_BEF).to_i(26), value[1].to_i(10)-1
        elsif value.downcase.match(/^[0-9]+[^0-9]+[0-9]+$/)
          value = value.downcase.split(/[^0-9]+/)
          @x, @y = value[0].to_i(10), value[1].to_i(10)
        end
      elsif value.is_a? Integer
        @x, @y = (value >> X_BIT_SHIFT), value & Y_FILTER
      elsif value.is_a? Coordinates
        @x, @y = value.x, value.y
      elsif value.is_a? Array
        @x, @y = value[0].to_i, value[1].to_i
      elsif value.is_a? Hash
        @x, @y = value[:x] || value[:column] || 0, value[:y] || value[:row] || 0
      end
    end

    def to_s
      @x.to_s(26).tr(BASE_26_BEF, BASE_26_AFT).upcase+(@y+1).to_s(10)
    end

    def to_a
      [@x, @y]
    end

    def to_hash
      {:x=>@x, :y=>@y}
    end
    
    def to_i
      (@x << X_BIT_SHIFT) + @y
    end

    def ==(other_coordinate)
      other_coordinate.x == self.x and other_coordinate.y == self.y
    end

    def <=>(other_coordinate)
      self.to_i <=> other_coordinate.to_i
    end
  end

end
