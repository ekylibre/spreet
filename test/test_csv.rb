# encoding: utf-8
require 'helper'

class TestCSV < Test::Unit::TestCase
  
  def test_read_and_write
    doc = nil
    assert_nothing_raised do
      doc = Spreet::Document.read("test/samples/pascal.csv")
    end

    sheet = doc.sheets[0]
    sheet.each_row do |row|
      for cell in row
        if cell.text.to_i == 0
          cell.clear!
        end
      end
    end
    
    doc.write("test/samples/cleaned-pascal.csv")

    doc.write("test/samples/cleaned-pascal.xcsv")
    doc.write("test/samples/cleaned-pascal-excel.csv", :format=>:xcsv)

    assert_checksums "test/samples/cleaned-pascal.xcsv", "test/samples/cleaned-pascal-excel.csv"

    assert_nothing_raised do
      doc = Spreet::Document.read("test/samples/cleaned-pascal.csv")
    end

    assert_nothing_raised do
      doc = Spreet::Document.read("test/samples/cleaned-pascal.xcsv")
    end

    FileUtils.rm_f("test/samples/cleaned-pascal*")
  end

end
