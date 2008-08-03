require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class GeocoderUsTest < Test::Unit::TestCase

      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []

        @geocoder = GeocoderUs.new
        @location = Location.new(
          :street => "1600 Pennsylvania Ave NW, Washington DC 20502",
          :longitude => -77.037684,
          :latitude => 38.898748
        )
      end

      def test_success
        prepare_response(:success)
        assert_equal @location, @geocoder.locate('1600 Pennsylvania Ave, Washington DC')
      end
    
      def test_url
        prepare_response(:success)
        @geocoder.locate('1600 Pennsylvania Ave, Washington DC')
        assert_equal 'http://rpc.geocoder.us/service/rest/geocode?address=1600%20Pennsylvania%20Ave,%20Washington%20DC',
                     URI::HTTP.uris.first
      end

      def test_locate_bad_address
        prepare_response(:unknown)
        assert_raises(AddressError) { @geocoder.locate('yuck') }
      end

    protected
      def prepare_response(id)
        URI::HTTP.responses << response('geocoder_us', id)
      end

    end
  end
end