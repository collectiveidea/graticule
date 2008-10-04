require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class MultimapTest < Test::Unit::TestCase

      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Multimap.new 'API_KEY'
        @location = Location.new(
          :street => "Oxford Street",
          :locality => "London",
          :postal_code => "W1",
          :country => "GB",
          :longitude => -0.14839,
          :latitude => 51.51452,
          :precision => :address
        )
      end

    def test_locate
      prepare_response(:success)
      assert_equal @location, @geocoder.locate('Oxford Street, LONDON, W1')
    end

    def test_url_from_string
      prepare_response(:success)
      @geocoder.locate('Oxford Street, LONDON, W1')
      assert_equal 'http://clients.multimap.com/API/geocode/1.2/API_KEY?qs=Oxford%20Street,%20LONDON,%20W1', URI::HTTP.uris.first
    end
    
    def test_url_from_location
      prepare_response(:success)
      @geocoder.locate(:street => 'Oxford Street', :city => 'London')
      assert_equal 'http://clients.multimap.com/API/geocode/1.2/API_KEY?city=&countryCode=&postalCode=&region=&street=Oxford%20Street', URI::HTTP.uris.first
    end


    def test_locate_bad_address
      prepare_response(:no_matches)
      assert_raise(Error) { @geocoder.locate('yucksthoeusthaoeusnhtaosu') }
    end

    protected
      def prepare_response(id)
        URI::HTTP.responses << response('multimap', id)
      end

    end
  end
end