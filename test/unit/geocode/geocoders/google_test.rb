require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/geocoders'

module Geocode
  class GoogleGeocoderTest < Test::Unit::TestCase
    # run tests from Geocode::GeocodersTest
    include Geocode::GeocodersTestCase
    
    def setup
      URI::HTTP.responses = []
      URI::HTTP.uris = []
      @geocoder = GoogleGeocoder.new(:key => 'APP_ID')
    end
    
    protected

      def prepare_response(id = :success)
        URI::HTTP.responses << response('google', id)
      end
    
  end
end
