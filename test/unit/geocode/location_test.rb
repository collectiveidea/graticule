require File.dirname(__FILE__) + '/../../test_helper'

module Geocode
  class LocationTest < Test::Unit::TestCase
  
    def test_responds_to
      [:latitude, :longitude, :street, :city, :state, :zip, :country, :coordinates, :precision].each do |m|
        assert Location.new.respond_to?(m), "should respond to #{m}"
      end
    end
  
    def test_coordinates
      l = Location.new(:latitude => 100, :longitude => 50)
      assert_equal [100, 50], l.coordinates
    end
    
    def test_equal
      assert_equal Location.new, Location.new

      attrs = {:latitude => 100.5389, :longitude => -147.5893, :street => '123 A Street',
          :city => 'Somewhere', :state => 'NO', :zip => '12345', :country => 'USA', :precision => :address}
      
      assert_equal Location.new(attrs), Location.new(attrs)
      attrs.each do |k,v|
        assert_equal Location.new(k => v), Location.new(k => v)
        assert_not_equal Location.new, Location.new(k => v)
        assert_not_equal Location.new(attrs), Location.new(attrs.update(k => nil))
      end
    end

  end
end