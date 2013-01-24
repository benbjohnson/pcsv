require 'test_helper'

class TestPCSV < MiniTest::Unit::TestCase
  ######################################
  # Each
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


  ######################################
  # Map
  ######################################
  
  def test_map
    csv = PCSV.map('fixtures/simple.csv', :headers => true) do |item, mutex|
      item[:value].to_i + 100
    end
    
    assert_equal IO.read('fixtures/simple.map.csv'), csv.to_csv
  end

  def test_map_error
    csv = PCSV.map('fixtures/simple.csv', :headers => true) do |item, mutex|
      if item[:value] == '30'
        raise 'OH NO!'
      else
        item[:value].to_i + 100
      end
    end
    
    assert_equal IO.read('fixtures/simple.map_error.csv'), csv.to_csv
  end
end
