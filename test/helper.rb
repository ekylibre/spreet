require 'bundler/setup'
require 'minitest/autorun'

require "digest/sha2"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'spreet'

FileUtils.mkdir_p("tmp") unless File.exist?("tmp")

class SpreetTest < MiniTest::Test

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

  def assert_nothing_raised(*args, &block)
    yield
  end

  def assert_raise(exception, *args, &block)
    begin
      yield
      assert false, "No #{exception.name} raised."
    rescue exception => e
      assert e.class == exception, *args
    end
  end
  
  def assert_not_nil(value, *args)
    assert !value.nil?, *args
  end
  
  
end
