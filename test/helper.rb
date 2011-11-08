require 'rubygems'
require 'test/unit'
require "digest/sha2"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spreet'

class Test::Unit::TestCase

  def assert_checksums(expected, actual, message=nil)
    checksums = []
    assert File.exist?(expected)
    File.open(expected, "rb") do |f|
      checksums << Digest::SHA256.hexdigest(f.read)
    end
    assert File.exist?(actual)
    File.open(actual, "rb") do |f|
      checksums << Digest::SHA256.hexdigest(f.read)
    end
    assert_equal checksums[0], checksums[1], message
  end

end
