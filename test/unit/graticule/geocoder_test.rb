require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module Graticule
  class GeocoderTest < Test::Unit::TestCase

    def test_bogus_service
      assert_equal Geocoder::Bogus, Graticule.service(:bogus)
    end

    def test_yahoo_service
      assert_equal Geocoder::Yahoo, Graticule.service(:yahoo)
    end

    def test_google_service
      assert_equal Geocoder::Google, Graticule.service(:google)
    end

    def test_geocoder_us_service
      assert_equal Geocoder::GeocoderUs, Graticule.service(:geocoder_us)
    end

    def test_meta_carta_service
      assert_equal Geocoder::MetaCarta, Graticule.service(:meta_carta)
    end
  
  end
end