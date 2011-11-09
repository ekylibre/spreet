# encoding: utf-8
require 'helper'

class TestBigHash < Test::Unit::TestCase

  def test_big_hash
    assert_nothing_raised do
      BigHash.new("MyBigHash")
    end
    hash = nil
    assert_nothing_raised do
      hash = BigHash::MyBigHash.new
    end
    assert_nothing_raised do
      hash[0] = 123
    end
    assert_equal(123, hash[0])
    assert_nothing_raised do
      hash[2**32 - 1] = "Test"
    end
    assert_equal("Test", hash[2**32 - 1])
  end

end
