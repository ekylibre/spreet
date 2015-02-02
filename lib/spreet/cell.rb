require 'money'
require 'time'
require 'duration'

module Spreet

  # Represents a cell in a sheet
  class Cell
    attr_reader :text, :value, :type, :sheet, :coordinates
    attr_accessor :annotation

    def initialize(sheet, *args)
      @sheet = sheet
      @coordinates = Coordinates.new(*args)
      self.value = nil
      @empty = true
      @covered = false # determine_covered
      @annotation = nil
    end

    def value=(val)
      if val.is_a?(Cell)
        @value = val.value
        @type = val.type
        self.text = val.text
        @empty = val.empty?
        @annotation = val.annotation
      else
        @value = val
        @type = determine_type
        self.text = val
        @empty = false
      end
    end

    def empty?
      @empty
    end
    
    def covered?
      @covered
    end

    def clear!
      self.value = nil
      @empty = true
    end

    def remove!
      @sheet.remove(self.coordinates)
    end

    def <=>(other_cell)
      self.coordinates <=> other_cell.coordinates
    end

    def text=(val)
      @text = val.to_s
    end

    def inspect
      "<#{self.coordinates}: #{self.text.inspect}#{'('+self.value.inspect+')' if self.text != self.value}>"
    end

    private

    
    def determine_type
      if value.is_a? Date or value.is_a? DateTime
        :date
      elsif value.is_a? Numeric # or percentage
        :float
      elsif value.is_a? Money
        :currency
      elsif value.is_a? Duration
        :time
      elsif value.is_a?(TrueClass) or value.is_a?(FalseClass)
        :boolean
      else # if value.is_a?(String)
        :string
      end
    end

  end


end
