require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class YahooTest < Test::Unit::TestCase

      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Yahoo.new 'APP_ID'
        @location = Location.new(
          :street => "701 First Ave",
          :locality => "Sunnyvale",
          :region => "CA",
          :postal_code => "94089-1019",
          :country => "US",
          :longitude => -122.024853,
          :latitude => 37.416384,
          :precision => :address
        )
      end

    def test_locate
      prepare_response(:success)
      assert_equal @location, @geocoder.locate('701 First Street, Sunnyvale, CA')
    end
  
    def test_url
      prepare_response(:success)
      @geocoder.locate('701 First Street, Sunnyvale, CA')
      assert_equal 'http://api.local.yahoo.com/MapsService/V1/geocode?appid=APP_ID&location=701%20First%20Street,%20Sunnyvale,%20CA&output=xml',
                   URI::HTTP.uris.first
    end
  

    def test_locate_bad_address
      prepare_response(:unknown_address)
      assert_raise(Error) { @geocoder.locate('yucksthoeusthaoeusnhtaosu') }
    end

    protected
      def prepare_response(id)
        URI::HTTP.responses << response('yahoo', id)
      end
  
    end
  end
end