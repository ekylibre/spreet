module Spreet

  class Sheet
    attr_reader :document, :name, :columns
    attr_accessor :current_row

    def initialize(document, name=nil)
      @document = document
      self.name = name
      raise ArgumentError.new("Must be a Document") unless document.is_a? Document
      @current_row = 0
      @cells = {} # BigArray::Cells.new
      @bound = compute_bound
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

    def [](*args)
      coord = Coordinates.new(*args)
      @cells[coord.to_i] ||= Cell.new(self, coord)
      return @cells[coord.to_i]
    end

    def []=(*args)
      value = args.delete_at(-1)
      cell = self[*args]
      cell.value = value
      @updated = true
    end

    def row(*args)
      options = {}
      options = args.delete_at(-1) if args[-1].is_a? Hash
      row = options[:row] || @current_row
      args.each_index do |index|
        self[index, row] = args[index]
      end
      next_row
    end

    def rows(index)
      row = []
      for i in 0..bound.x
        row[i] = self[i, index]
      end
      return row
    end

    def each_row(&block)
      for j in 0..bound.y
        yield rows(j)
      end
    end

    # Find or build cell
    def cell(*args)
      return c
    end
    
    def bound
      if @updated
        compute_bound
      else
        @bound
      end
    end

    def remove!(coordinates)
      raise ArgumentError.new("Must be a Coordinates") unless document.is_a?(Coordinates)
      @cells.delete(coordinates.to_i)
      @updated = true
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

    private

    def compute_bound
      bound = Coordinates.new(0,0)
      for index, cell in @cells
      # for cell in @cells.compact
        unless cell.empty?
          bound.x = cell.coordinates.x if cell.coordinates.x > bound.x
          bound.y = cell.coordinates.y if cell.coordinates.y > bound.y
        end
      end
      @updated = false
      @bound = bound
      return @bound
    end

  end
  

end
