# encoding: utf-8
require 'helper'

class TestDuration < Test::Unit::TestCase

  # Test syntax like defined for xsd:duration
  def test_importations
    # Valid values include PT1004199059S, PT130S, PT2M10S, P1DT2S, -P1Y, or P1Y2M3DT5H20M30.123S.
    for value in ["PT1004199059S", "PT130S", "PT2M10S", "P1DT2S", "-P1Y", "P1Y2M3DT5H20M30.123S"]
      duration = nil
      assert_nothing_raised do
        duration = Duration.new(value)
      end
      assert_equal value, duration.to_s(:maximum)
    end

    # The following values are invalid: 1Y (leading P is missing), P1S (T separator is missing), P-1Y (all parts must be positive), P1M2Y (parts order is significant and Y must precede M), or P1Y-1M (all parts must be positive).
    for value in ["1Y", "P1S", "P-1Y", "P1M2Y", "P1Y-1M"]
      assert_raise(ArgumentError) do
        Duration.new(value)
      end
    end
    
    duration = Duration.new("P5Y250M1D")
    assert_not_nil duration    
  end

  def test_normalization
    duration = Duration.new("PT1004199059S")
    assert_equal duration.to_i, duration.normalize(:right).to_i
    assert_equal duration.to_i, duration.normalize(:seconds).to_i
  end
  
end
