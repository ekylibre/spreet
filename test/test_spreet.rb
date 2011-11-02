# encoding: utf-8
require 'helper'

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
  


  def test_spreet
    assert_not_nil Spreet

    spreet = Spreet::Document.new
    assert_not_nil spreet
    sheet = spreet.sheets.add
    assert_not_nil sheet
    assert_not_nil spreet.sheets.add("Feuille 2")
    assert_not_nil spreet.sheets.add("ソフト 3")

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

    puts spreet.to_term

  end

end


