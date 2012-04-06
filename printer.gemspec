# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "printer"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Adam"]
  s.date = "2012-04-06"
  s.email = "james@lazyatom.com"
  s.files = ["Gemfile", "test/printer_test.rb", "test/test_helper.rb", "lib/printer.rb", "lib/serial_connection.rb"]
  s.homepage = "http://lazyatom.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Sending commands to a small thermal printer"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
