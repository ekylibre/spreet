# encoding: utf-8
require 'csv'

module Spreet
  # Universal CSV support
  CSV = (::CSV.const_defined?(:Reader) ? ::FasterCSV : ::CSV).freeze

  class Coordinates
    # Limit coordinates x and y in 0..65535 but coordinates are in one integer of 32 bits
    CPU_SEMI_WIDTH = 16 # ((RUBY_PLATFORM.match(/^[^\-]*[^\-0-9]64/) ? 64 : 32) / 2).freeze
    Y_FILTER = ((1 << CPU_SEMI_WIDTH) - 1).freeze

    attr_accessor :x, :y
    def initialize(*args)
      value = (args.size == 1 ? args[0] : args)
      @x, @y = 0, 0
      if value.is_a? String
        if value.downcase.match(/^[a-z]+[0-9]+$/)
          value = value.downcase.split(/([A-Z]+|[0-9]+)/).delete_if{|x| x.size.zero?}
          @x, @y = value[0].to_i(36), value[1].to_i(10)
        elsif value.downcase.match(/^[0-9]+[^0-9]+[0-9]+$/)
          value = value.downcase.split(/[^0-9]+/)
          @x, @y = value[0].to_i(10), value[1].to_i(10)
        end
      elsif value.is_a? Integer
        @x, @y = (value >> CPU_SEMI_WIDTH), value & Y_FILTER
      elsif value.is_a? Coordinate
        @x, @y = value.x, value.y
      elsif value.is_a? Array
        @x, @y = value[0].to_i, value[1].to_i
      elsif value.is_a? Hash
        @x, @y = value[:x] || value[:column] || 0, value[:y] || value[:row] || 0
      end
    end

    def to_s
      @x.to_s(36)+@y.to_s(10)
    end

    def to_a
      [@x, @y]
    end

    def to_hash
      {:x=>@x, :y=>@y}
    end
    
    def to_i
      (@x << CPU_SEMI_WIDTH) + @y
    end
  end

  class Cell
    def initialize(cells, *args)
      @cells = cells
      @coordinates = Coordinates.new(*args)
    end
  end

  class Columns
  end

  class Cells
    def initialize(sheet)
      @sheet = sheet
      @cells = {}
    end

    def [](*args)
      coord = Coordinates.new(*args)
      return @cells[coord.to_i] || Cell.new(self, coord)
    end
    
    def []=(*args)
      raise args.inspect
      # cell = self[]
    end
    
  end

  class Sheet
    attr_reader :document, :name, :columns, :cells
    attr_accessor :current_row

    def initialize(document, name=nil)
      @document = document
      self.name = name
      raise ArgumentError.new("Must be a Document") unless document.is_a? Document
      @current_row = 0
      @cells = Cells.new(self)
    end

    def name=(value)
      unless value
        value = (@document.sheets.count > 0 ? @document.sheets[-1].name.succ : "Sheet 1")
      end 
      raise ArgumentError.new("Name of sheet must be given") if value.to_s.strip.size.zero?
      if @document.sheets[value]
        raise ArgumentError.new("Name of sheet must be unique")
      end
      @name = value
    end

    def next_row(increment = 1)
      @current_row += increment
    end
    
    def previous_row(increment = 1)
      @current_row -= increment
    end

    def row(*args)
      options = args.delete_at(-1) if args[-1].is_a? Hash
      row = options[:row] || @current_row
      args.each_index do |index|
        cells[index, row] = args[index]
      end
      next_row
    end

    # Find or build cell
    def cell(*args)
      return c
    end
    

    # Moves the sheet to an other position in the list of sheets
    def move_to(position)
      @document.sheets.move_at(self, position)
    end

    # Moves the sheet higher in the list of sheets
    def move_higher(increment=1)
      @document.sheets.move(self, increment)
    end

    # Moves the sheet lower in the list of sheets
    def move_lower(increment=1)
      @document.sheets.move(self, -increment)
    end

  end


  class Sheets

    def initialize(document)
      raise ArgumentError.new("Must be a Document") unless document.is_a? Document      
      @document = document
      @array = []
    end

    def count
      @array.size
    end

    def index(name_or_sheet)
      if name_or_sheet.is_a? String
        @array.each_index do |i|
          return i if @array[i].name == name_or_sheet
        end
      else
        return @array.index(name_or_sheet)
      end
    end

    def add(name=nil, position=-1)
      @array.insert(position, Sheet.new(@document, name))
    end

    def [](sheet)
      sheet = index(sheet)
      return (sheet.is_a?(Integer) ? @array[sheet] : nil)
    end

    def remove(sheet)
      @array.delete(sheet)
    end

    def move(sheet, shift=0)
      move_at(sheet, index(sheet) + shift)
    end

    def move_at(sheet, position=-1)
      if i = index(sheet)
        @array.insert(position, @array.delete_at(i))
      end
    end

    def each(&block)
      for item in @array
        yield item
      end
    end

  end


  class Document
    attr_reader :sheets
    
    def initialize(option={})
      @sheets = Sheets.new(self)
    end
    
    def to_term
      text = "Spreet (#{@sheets.count}):\n"
      for sheet in @sheets
        text << " - #{sheet.name}:\n"
      end
      return text
    end

  end  

end
