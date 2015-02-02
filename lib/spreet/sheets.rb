module Spreet

  class Sheets

    def initialize(document)
      raise ArgumentError.new("Must be a Document") unless document.is_a?(Document)
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
      elsif name_or_sheet.is_a? Integer
        return (@array[name_or_sheet].nil? ? nil : name_or_sheet)
      else
        return @array.index(name_or_sheet)
      end
    end

    def add(name=nil, position=-1)
      sheet = Sheet.new(@document, name)
      @array.insert(position, sheet)
      return sheet
    end

    def [](sheet)
      sheet = index(sheet)
      return (sheet.is_a?(Integer) ? @array[sheet] : nil)
    end

    def remove(sheet)
      @array.delete_at(index(sheet))
    end

    def move(sheet, shift=0)
      position = index(sheet) + shift
      position = 0 if position < 0
      position = self.count-1 if position >= self.count
      move_at(sheet, position)
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
  
end
