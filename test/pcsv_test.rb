require 'test_helper'

class TestPCSV < MiniTest::Unit::TestCase
  ######################################
  # Map
  ######################################
  
  def test_each
    obj = {}
    csv = PCSV.each('fixtures/simple.csv', :headers => true) do |item, mutex|
      mutex.synchronize {
        obj[item[:value].to_i] = true
      }
    end
    
    exp = []
    (0...50).each {|i| exp << i}
    assert_equal exp, obj.keys.sort
  end
end
