# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class MapboxTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Mapbox.new("api_key")
      end

      def test_locate_success
        prepare_response(:success)

        expected = Location.new(
          :latitude    => 37.331524,
          :longitude   => -122.03023,
        )

        actual = @geocoder.locate("1 Infinite Loop, Cupertino, CA")

        assert_equal(expected, actual)
      end

      def test_locate_not_found
        prepare_response(:empty_results)

        assert_raises(AddressError) { @geocoder.locate 'asdfjkl' }
      end

      def test_no_results_returned
        prepare_response(:no_results)

        assert_raises(AddressError) { @geocoder.locate 'asdfjkl' }
      end

      protected

      def prepare_response(id = :success)
        URI::HTTP.responses << response('mapbox', id, 'json')
      end
    end
  end
end
