require "rubygems"
require "bundler/setup"
$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "serial_connection"

c = SerialConnection.new
File.open("printer.data", "rb") do |f|
  f.each_byte { |b| c.putc(b) }
end