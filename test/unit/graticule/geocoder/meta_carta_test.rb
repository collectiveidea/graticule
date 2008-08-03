require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class MetaCartaTest < Test::Unit::TestCase

      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []

        @geocoder = MetaCarta.new
      end

      def test_locate
        prepare_response(:success)

        expected = Location.new :latitude => 44.3939, :longitude => 33.3386
        
        assert_equal expected, @geocoder.locate('baghdad')
        assert_equal true, URI::HTTP.responses.empty?
        assert_equal 1, URI::HTTP.uris.length
        assert_equal 'http://labs.metacarta.com/GeoParser/?output=locations&q=baghdad',
                     URI::HTTP.uris.first
      end

      def test_locate_bad_address
        prepare_response(:bad_address)
        assert_raises(AddressError) { @geocoder.locate('aoeueou') }
      end

      def test_locations
        prepare_response(:multiple)
        expected = Location.new :latitude => -122.33083, :longitude => 47.60639
        assert_equal expected, @geocoder.locate('seattle')
      end

    protected
      def prepare_response(id = :success)
        URI::HTTP.responses << response('meta_carta', id)
      end

    end
  end
end