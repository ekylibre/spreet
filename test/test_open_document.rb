# encoding: utf-8
require 'helper'

class TestOpenDocument < SpreetTest

  def test_read_and_write
    doc = Spreet::Document.read("test/samples/pascal.ods")
    sheet = doc.sheets["Datatypes"]

    assert_equal 12.34,  sheet["A2"].value.to_f
    assert_equal 123.45, sheet["A3"].value.to_f
    assert_equal 123456, sheet["A4"].value.to_f
    
    doc.write("tmp/rewrited-pascal.ods")
  end

end
