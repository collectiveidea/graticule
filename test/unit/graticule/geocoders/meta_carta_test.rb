require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/geocoders'

module Graticule
  class MetaCartaGeocoderTest < Test::Unit::TestCase

    def setup
      URI::HTTP.responses = []
      URI::HTTP.uris = []

      @geocoder = MetaCartaGeocoder.new
    end

    def test_locate
      prepare_response(:success)

      expected = MetaCartaGeocoder::Location.new 'Baghdad', 'PPLC', 5672516,
                                                  'Iraq/Baghdad/Baghdad',
                                                  44.393889, 33.338611, 0.195185,
                                                  [[26.238611, 37.293889],
                                                   [40.438611, 51.493889]]

      location = @geocoder.locate('baghdad')
      assert_equal expected, location
      assert_equal [44.393889, 33.338611], location.coordinates

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

      expected = [
        MetaCartaGeocoder::Location.new('Seattle', 'PPL', 563374,
                                         'United States/Washington/King/Seattle',
                                         -122.33083, 47.60639, nil,
                                         [[43.806390, -126.130830],
                                          [51.406390, -118.530830]]),
        MetaCartaGeocoder::Location.new('Seattle', 'PRT', nil,
                                         'United States/Seattle',
                                         -122.333333, 47.6, nil,
                                         [[43.8, -126.133333],
                                          [51.4, -118.533333]]),
      ]

      locations, viewbox = @geocoder.locations('seattle')
      assert_equal expected, locations
      assert_equal [[43.8, -126.133333], [51.40639, -118.53083]], viewbox

      assert_equal true, URI::HTTP.responses.empty?
      assert_equal 1, URI::HTTP.uris.length
      assert_equal 'http://labs.metacarta.com/GeoParser/?loc=seattle&output=locations',
                   URI::HTTP.uris.first
    end

  protected
    def prepare_response(id = :success)
      URI::HTTP.responses << response('meta_carta', id)
    end

  end
end