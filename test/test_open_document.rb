# encoding: utf-8
require 'helper'

class TestOpenDocument < SpreetTest

  def test_read_and_write
    doc = nil
    assert_nothing_raised do
      doc = Spreet::Document.read("test/samples/pascal.ods")
    end

    assert_nothing_raised do
      doc.write("tmp/rewrited-pascal.ods")
    end
  end

end
