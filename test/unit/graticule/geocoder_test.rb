require File.dirname(__FILE__) + '/../../test_helper'

module Graticule
  class GeocoderTest < Test::Unit::TestCase

    def test_cannot_instantiate
      assert_raises(NotImplementedError) { Geocoder.new }
    end
    
    def test_service
      assert_equal BogusGeocoder, Graticule.service(:bogus)
    end
  
  end
end