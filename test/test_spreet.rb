# encoding: utf-8
require 'helper'
require "digest/sha2"

class TestSpreet < Test::Unit::TestCase
  
  def test_version
    assert_not_nil Spreet::VERSION
    assert_not_nil Spreet::VERSION::MAJOR
    assert_not_nil Spreet::VERSION::MINOR
    assert_not_nil Spreet::VERSION::TINY
    assert_not_nil Spreet::VERSION::PATCH
    assert_equal(Spreet::VERSION::TINY, Spreet::VERSION::PATCH, "PATCH code must have the same value as TINY")
    assert((Spreet::VERSION::MAJOR > 0 or Spreet::VERSION::MINOR > 0 or Spreet::VERSION::TINY > 0), "Version cannot be 0.0.0")
  end

  def test_spreet
    assert_not_nil Spreet

    spreet = Spreet::Document.new
    assert_not_nil spreet
    assert_equal 0, spreet.sheets.count
    sheet = spreet.sheets.add
    assert_not_nil sheet
    assert_equal 1, spreet.sheets.count
    assert_not_nil spreet.sheets.add("Feuille 2")
    assert_equal 2, spreet.sheets.count
    assert_not_nil spreet.sheets.add("ソフト 3")
    assert_equal 3, spreet.sheets.count
    assert_not_nil spreet.sheets.add("Feuille 4")
    assert_equal 4, spreet.sheets.count
    spreet.sheets.remove("Feuille 2")
    assert_equal 3, spreet.sheets.count
    assert_equal "Sheet 1", spreet.sheets[0].name
    assert_equal "ソフト 3", spreet.sheets[1].name
    assert_equal "Feuille 4", spreet.sheets[2].name
    spreet.sheets[2].name = "Feuille 2"
    spreet.sheets.move("Feuille 2", -1)
    assert_equal 1, spreet.sheets.index("Feuille 2")
    spreet.sheets.move("Feuille 2", -10)
    assert_equal 0, spreet.sheets.index("Feuille 2")
    spreet.sheets.move("Feuille 2", +10)
    assert_equal 2, spreet.sheets.index("Feuille 2")
    spreet.sheets.move_at("Feuille 2", 1)
    assert_equal 1, spreet.sheets.index("Feuille 2")
    assert_equal "Sheet 1", spreet.sheets[0].name
    assert_equal "Feuille 2", spreet.sheets[1].name
    assert_equal "ソフト 3", spreet.sheets[2].name
    spreet.sheets.add "Empty sheet"
    assert_equal 4, spreet.sheets.count

    assert_equal Spreet::Sheet, spreet.sheets[1].class
    assert_equal "Feuille 2", spreet.sheets[1].name
    
    assert_equal Spreet::Sheet, spreet.sheets["ソフト 3"].class
    assert_equal "ソフト 3", spreet.sheets["ソフト 3"].name

    assert_not_nil sheet[0,0]
    sheet[0,0] = "Cell A1"
    spreet.sheets[1][0] = "Cellule A1"
    spreet.sheets["ソフト 3"]["A1"] = "セル A1"
 
    assert_not_nil sheet["C30"]

    sheet["F20"] = Date.today
    sheet["F20"].annotation = "Date.today"

    spreet.write("test/samples/cleaned-nothing.ods")

    spreet2 = Spreet::Document.read("test/samples/cleaned-nothing.ods")

    spreet2.write("test/samples/cleaned-nothing2.ods")

    # Assert equality of file size ?
    assert_checksums "test/samples/cleaned-nothing.ods", "test/samples/cleaned-nothing2.ods", "SHA256 sums differs between the copy and the original. Check if the reader is a good 'mirror' of the writer..." 
  end
  

  def test_pascal
    size = 25
    doc = Spreet::Document.new
    sheet = doc.sheets.add("Pascal Tree")
    sheet[0,0] = 1
    start = Time.now
    for y in 1..(size-1)
      sheet[0,y] = 1
      for x in 1..(size-1)
        sheet[x,y] = sheet[x,y-1].value.to_i + sheet[x-1,y-1].value.to_i
        sheet[x,y].clear! if sheet[x,y].value.zero?
      end
    end
    stop = Time.now
    sheet["B1"] = "Computed in #{stop-start} seconds"

    assert_equal size-1, sheet.bound.x
    assert_equal size-1, sheet.bound.y

    assert_nothing_raised do
      doc.write("test/samples/pascal-tree-#{size}.ods")
    end
    assert_nothing_raised do
      doc.write("test/samples/pascal-tree-#{size}.csv")
    end
    assert_nothing_raised do
      doc.write("test/samples/pascal-tree-#{size}.xcsv")
    end
  end



end


