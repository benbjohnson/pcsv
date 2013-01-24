require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'
require 'unindentable'
require 'pcsv'

class MiniTest::Unit::TestCase
  def assert_worksheet exp, worksheet, msg = nil
    act = []
    worksheet.each do |row|
      act << row.map {|cell| cell.to_s.strip }
    end
    exp = exp.map {|row| row.map {|cell| '%-10s' % cell.to_s}.join('').rstrip}.join("\n")
    act = act.map {|row| row.map {|cell| '%-10s' % cell.to_s}.join('').rstrip}.join("\n")
    assert_equal(exp, act, msg)
  end
end

