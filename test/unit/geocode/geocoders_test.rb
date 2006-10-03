require File.dirname(__FILE__) + '/../../test_helper'
require 'pp'
module Geocode
  class GeocodersTest < Test::Unit::TestCase

    GEOCODERS = [:google]
  
    def setup
      @geocoders = {}
      GEOCODERS.each do |geocoder|
        @geocoders[geocoder] = Geocoder.service(geocoder).new
      end
    end
    
    def test_success
      @geocoders.each do |name,geocoder|
        location = geocoder.parse_response(response(name, :success))
        assert_equal "1600 Amphitheatre Pkwy", location.street 
        assert_equal "Mountain View", location.city
        assert_equal "CA", location.state
        assert_equal "94043", location.zip
        assert_equal "US", location.country
        assert_equal -122.083739, location.longitude
        assert_equal 37.423021, location.latitude
        assert_equal :address, location.precision
      end
    end
  end
end
