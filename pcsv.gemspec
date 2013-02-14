# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)

require 'pcsv/version'

Gem::Specification.new do |s|
  s.name        = "pcsv"
  s.version     = PCSV::VERSION
  s.authors     = ["Ben Johnson"]
  s.email       = ["benbjohnson@yahoo.com"]
  s.homepage    = "http://github.com/benbjohnson/pcsv"
  s.summary     = "A simple, parallel processing framework for CSV files."

  s.add_dependency('ruby-progressbar', '~> 1.0.2')

  s.add_development_dependency('rake', '~> 0.9.2.2')
  s.add_development_dependency('minitest', '~> 3.5.0')
  s.add_development_dependency('mocha', '~> 0.12.5')
  s.add_development_dependency('unindentable', '~> 0.1.0')

  s.test_files   = Dir.glob("test/**/*")
  s.files        = Dir.glob("lib/**/*") + %w(README.md)
  s.require_path = 'lib'
end
