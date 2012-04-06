require "minitest/autorun"
require "rubygems"
require "bundler"
Bundler.require(:default, :test)
require "mocha"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

class TestConnection
  attr_reader :bytes
  def initialize
    @bytes = []
  end
  def putc(byte)
    @bytes << byte
  end
end
    