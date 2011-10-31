# encoding: utf-8
require 'helper'

class TestSpreet < Test::Unit::TestCase
  
  def test_existence
    assert_not_nil Spreet

    spreet = Spreet::Document.new
    sheet = spreet.sheets.add
    spreet.sheets.add "Feuille 2"
    spreet.sheets.add "ソフト 3"

    sheet.cells[0,0] = "Cell A1"

    puts spreet.to_term

  end

end


