# encoding: utf-8
require 'helper'

class TestCoordinates < Test::Unit::TestCase
  
  def test_importations
    assert_equal Spreet::Coordinates.new(0,0), Spreet::Coordinates.new("A1")
    assert_equal Spreet::Coordinates.new(0,0), Spreet::Coordinates.new("0-0")
    assert_equal Spreet::Coordinates.new(1,1), Spreet::Coordinates.new("B2")
    assert_equal Spreet::Coordinates.new(2,2), Spreet::Coordinates.new(:x=>2, :y=>2)
    assert_equal Spreet::Coordinates.new(3,3), Spreet::Coordinates.new(3,3)
    assert_equal Spreet::Coordinates.new(3,3), Spreet::Coordinates.new([3,3])
    assert_equal Spreet::Coordinates.new(4,4), Spreet::Coordinates.new(Spreet::Coordinates.new(4,4).to_i)
    assert_equal Spreet::Coordinates.new(5,5), Spreet::Coordinates.new(Spreet::Coordinates.new(5,5))
  end

  def test_exportations
    assert_equal("D25", Spreet::Coordinates.new(3,24).to_s)
    assert_equal([3, 24], Spreet::Coordinates.new(3,24).to_a)
    assert_equal({:x=>3, :y=>24}, Spreet::Coordinates.new(3,24).to_hash)
    assert_equal(24, Spreet::Coordinates.new(0,24).to_i)
    assert_equal((3 << Spreet::Coordinates::CPU_SEMI_WIDTH)+24, Spreet::Coordinates.new(3,24).to_i)
  end

  def test_sorting
    assert Spreet::Coordinates.new(0,0) <=> Spreet::Coordinates.new(0,1)
    assert Spreet::Coordinates.new(0,1) <=> Spreet::Coordinates.new(1,0)
    assert Spreet::Coordinates.new(1,0) <=> Spreet::Coordinates.new(1,1)
  end
  
end
