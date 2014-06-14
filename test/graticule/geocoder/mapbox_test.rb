# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class MapboxTest < Test::Unit::TestCase
      def setup
        @geocoder = Mapbox.new("api_key")
      end

      def test_locate_success
        URI::HTTP.responses << response("mapbox", "success", "json")

        expected = Location.new(
          :country     => "United States",
          :latitude    => 37.33054,
          :longitude   => -122.02912,
          :street      => "1 Infinite Loop",
          :locality    => "Cupertino",
          :region      => "California",
          :postal_code => "95014",
          :precision   => :address
        )

        actual = @geocoder.locate("1 Infinite Loop, Cupertino, CA")

        assert_equal(expected, actual)
      end

      def test_locate_not_found
        URI::HTTP.responses << response("mapbox", "empty_results", "json")

        assert_raises(AddressError) { @geocoder.locate 'asdfjkl' }
      end
      
      def test_no_results_returned
        URI::HTTP.responses << response("mapbox", "no_results", "json")

        assert_raises(AddressError) { @geocoder.locate 'asdfjkl' }
      end
    end
  end
end
