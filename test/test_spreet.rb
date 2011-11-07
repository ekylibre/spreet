# encoding: utf-8
require 'helper'
require "digest/sha2"

class TestSpreet < Test::Unit::TestCase
  
  def test_coordinates
    assert_equal Spreet::Coordinates.new(0,0), Spreet::Coordinates.new("A1")
    assert_equal Spreet::Coordinates.new(0,0), Spreet::Coordinates.new("0-0")
    assert_equal Spreet::Coordinates.new(1,1), Spreet::Coordinates.new("B2")
    assert_equal Spreet::Coordinates.new(2,2), Spreet::Coordinates.new(:x=>2, :y=>2)
    assert_equal Spreet::Coordinates.new(3,3), Spreet::Coordinates.new(3,3)
    assert_equal Spreet::Coordinates.new(3,3), Spreet::Coordinates.new([3,3])
    assert_equal Spreet::Coordinates.new(4,4), Spreet::Coordinates.new(Spreet::Coordinates.new(4,4).to_i)
    assert_equal Spreet::Coordinates.new(5,5), Spreet::Coordinates.new(Spreet::Coordinates.new(5,5))
    assert_equal("D25", Spreet::Coordinates.new(3,24).to_s)
    assert_equal([3, 24], Spreet::Coordinates.new(3,24).to_a)
    assert_equal({:x=>3, :y=>24}, Spreet::Coordinates.new(3,24).to_hash)
    assert Spreet::Coordinates.new(0,0) <=> Spreet::Coordinates.new(0,1)
    assert Spreet::Coordinates.new(0,1) <=> Spreet::Coordinates.new(1,0)
  end
  
  def test_spreet_version
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

    spreet.write("test/samples/cleaned-nothing.ods")

    spreet2 = Spreet::Document.read("test/samples/cleaned-nothing.ods")

    spreet2.write("test/samples/cleaned-nothing2.ods")

    # Assert equality of file size ?
    checksums = []
    File.open("test/samples/cleaned-nothing.ods", "rb") do |f|
      checksums << Digest::SHA256.hexdigest(f.read)
    end
    File.open("test/samples/cleaned-nothing2.ods", "rb") do |f|
      checksums << Digest::SHA256.hexdigest(f.read)
    end
    assert_equal checksums[0], checksums[1], "SHA256 sums differs between the copy and the original. Check if the reader is a good 'mirror' of the writer..."
  end


  def test_handlers
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
    
    doc.write("test/samples/cleaned-pascal.csv", :format=>:xcsv)
    doc.write("test/samples/cleaned-pascal.ods")
    
    assert_nothing_raised do
      doc = Spreet::Document.read("test/samples/cleaned-pascal.csv", :format=>:xcsv)
    end

    FileUtils.rm_f("test/samples/cleaned-pascal.csv")
  end


  

end


