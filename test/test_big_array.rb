# encoding: utf-8
require 'helper'

class TestBigArray < Test::Unit::TestCase

  def test_big_hash
    assert_nothing_raised do
      BigArray.new("MyBigArray", 2, 8)
    end
    array = nil
    assert_nothing_raised do
      array = BigArray::MyBigArray.new
    end
    assert_nothing_raised do
      array[0] = 123
    end
    assert_equal(123, array[0])
    assert_nothing_raised do
      array[2**32 - 1] = "Test"
    end
    assert_equal("Test", array[2**32 - 1])
  end

end
