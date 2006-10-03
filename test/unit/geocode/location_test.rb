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

  end
end