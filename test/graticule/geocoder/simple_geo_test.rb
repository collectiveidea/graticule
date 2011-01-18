require 'test_helper'

module Graticule
  module Geocoder
    class SimpleGeoTest < Test::Unit::TestCase

      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = SimpleGeo.new('TOKEN')
      end

      def test_success
        return unless prepare_response(:success)

        location = Location.new(
          :longitude => -117.373982,
          :latitude => 34.482358,
          :precision => :unknown
        )
        assert_equal location, @geocoder.locate('1600 Amphitheatre Parkway, Mountain View, CA')
      end

      def test_error
        prepare_response :error
        assert_raises(Error) { @geocoder.locate('') }
      end

      def test_time_zone
        URI::HTTP.uris = []
        URI::HTTP.responses = []
        URI::HTTP.responses << response('simple_geo', :success, 'json')
        los_angeles = Location.new(:latitude => 34.48, :longitude => -117.37)
        assert_equal 'America/Los_Angeles', @geocoder.time_zone(los_angeles)
      end

    private

      def prepare_response(id = :success)
        URI::HTTP.responses << response('simple_geo', id, 'json')
      end
    end
  end
end