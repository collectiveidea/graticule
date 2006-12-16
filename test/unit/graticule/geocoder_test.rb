require File.dirname(__FILE__) + '/../../test_helper'

module Graticule
  class GeocoderTest < Test::Unit::TestCase

    def test_cannot_instantiate
      assert_raises(NotImplementedError) { Geocoder.new }
    end
    
    def test_bogus_service
      assert_equal BogusGeocoder, Graticule.service(:bogus)
    end

    def test_yahoo_service
      assert_equal YahooGeocoder, Graticule.service(:yahoo)
    end

    def test_google_service
      assert_equal GoogleGeocoder, Graticule.service(:google)
    end

    def test_geocoder_us_service
      assert_equal GeocoderUsGeocoder, Graticule.service(:geocoder_us)
    end

    def test_meta_carta_service
      assert_equal MetaCartaGeocoder, Graticule.service(:meta_carta)
    end
  
  end
end