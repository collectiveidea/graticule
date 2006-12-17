require File.dirname(__FILE__) + '/../../test_helper'

module Graticule
  class LocationTest < Test::Unit::TestCase
    
    def test_distance_to
      washington_dc = Location.new(:latitude => 38.898748, :longitude => -77.037684)
      chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
      assert_in_delta 594.820, washington_dc.distance_to(chicago), 1.0
    end
    
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
    
    def test_antipodal_location
      washington_dc = Location.new(:latitude => 38.898748, :longitude => -77.037684)
      chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
      
      assert_equal [-38.898748, 102.962316], washington_dc.antipodal_location.coordinates
      assert_equal [-41.85, 92.35], chicago.antipodal_location.coordinates
      
      assert_equal washington_dc.coordinates, washington_dc.antipodal_location.antipodal_location.coordinates
      assert_equal chicago.coordinates, chicago.antipodal_location.antipodal_location.coordinates
    end
  end
end