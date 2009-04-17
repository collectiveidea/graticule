require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module Graticule
  class LocationTest < Test::Unit::TestCase
    
    def setup
      @washington_dc = Location.new :latitude => 38.898748, :longitude => -77.037684,
        :street => '1600 Pennsylvania Avenue, NW', :locality => 'Washington',
        :region => 'DC', :postal_code => 20500, :country => 'US'
    end
    
    def test_distance_to
      chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
      assert_in_delta 594.820, @washington_dc.distance_to(chicago), 1.0
    end
    
    def test_responds_to
      [:latitude, :longitude, :street, :locality, :region, :postal_code, :country, :coordinates, :precision].each do |m|
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
          :locality => 'Somewhere', :region => 'NO', :postal_code => '12345', :country => 'USA'}
      
      assert_equal Location.new(attrs), Location.new(attrs)
      attrs.each do |k,v|
        assert_equal Location.new(k => v), Location.new(k => v)
        assert_not_equal Location.new, Location.new(k => v)
        assert_not_equal Location.new(attrs), Location.new(attrs.update(k => nil))
      end
    end
    
    def test_antipode
      chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
      
      assert_equal [-38.898748, 102.962316], @washington_dc.antipode.coordinates
      assert_equal [-41.85, 92.35], chicago.antipode.coordinates
      assert_equal [-41, -180], Graticule::Location.new(:latitude => 41, :longitude => 0).antipode.coordinates
      assert_equal [-41, 179], Graticule::Location.new(:latitude => 41, :longitude => -1).antipode.coordinates
      assert_equal [-41, -179], Graticule::Location.new(:latitude => 41, :longitude => 1).antipode.coordinates
      
      assert_equal @washington_dc.coordinates, @washington_dc.antipode.antipode.coordinates
      assert_equal chicago.coordinates, chicago.antipode.antipode.coordinates
    end
    
    def test_to_s
      assert_equal "1600 Pennsylvania Avenue, NW\nWashington, DC 20500 US",
        @washington_dc.to_s
      assert_equal "1600 Pennsylvania Avenue, NW\nWashington, DC 20500",
        @washington_dc.to_s(:country => false)
      assert_equal "1600 Pennsylvania Avenue, NW\nWashington, DC 20500",
        @washington_dc.to_s(:country => false)
      assert_equal "1600 Pennsylvania Avenue, NW\nWashington, DC 20500\nlatitude: 38.898748, longitude: -77.037684",
        @washington_dc.to_s(:country => false, :coordinates => true)
    end
    
    def test_blank?
      assert Location.new.blank?
      [:latitude, :longitude, :street, :locality, :region, :postal_code, :country].each do |attr|
        assert !Location.new(attr => 'Foo').blank?
      end
    end
  end
end