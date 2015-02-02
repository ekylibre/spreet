# encoding: utf-8
require 'helper'

class TestCSV < SpreetTest
  
  def test_read_and_write
    doc = Spreet::Document.read("test/samples/pascal.csv")

    sheet = doc.sheets[0]
    sheet.each_row do |row|
      for cell in row
        if cell.text.to_i == 0
          cell.clear!
        end
      end
    end
    
    doc.write("tmp/cleaned-pascal.csv")

    doc.write("tmp/cleaned-pascal.xcsv")
    doc.write("tmp/cleaned-pascal-excel.csv", :format=>:xcsv)

    assert_checksums "tmp/cleaned-pascal.xcsv", "tmp/cleaned-pascal-excel.csv"

    doc = Spreet::Document.read("tmp/cleaned-pascal.csv")
    
    doc = Spreet::Document.read("tmp/cleaned-pascal.xcsv")
  end

end
