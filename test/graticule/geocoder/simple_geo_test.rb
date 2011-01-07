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

    private

      def prepare_response(id = :success)
        URI::HTTP.responses << response('simple_geo', id, 'json')
      end
    end
  end
end