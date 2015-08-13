# -*- encoding: utf-8 -*-
# stub: a2_printer 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "a2_printer"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["James Adam"]
  s.date = "2015-08-13"
  s.email = "james@lazyatom.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["Gemfile", "README.md", "lib/a2_printer.rb", "lib/serial_connection.rb", "test/a2_printer_test.rb", "test/test_helper.rb"]
  s.homepage = "http://lazyatom.com"
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.4.5"
  s.summary = "Sending commands to a small thermal printer"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<serialport>, ["~> 1.3"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<serialport>, ["~> 1.3"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<serialport>, ["~> 1.3"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
