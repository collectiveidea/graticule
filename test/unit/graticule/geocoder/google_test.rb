require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class GoogleTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Google.new(:key => 'APP_ID')
      end
    
      def test_success
        return unless prepare_response(:success)
      
        location = Location.new(
          :street => "1600 Amphitheatre Pkwy",
          :locality => "Mountain View",
          :region => "CA",
          :postal_code => "94043",
          :country => "US",
          :longitude => -122.083739,
          :latitude => 37.423021,
          :precision => :address
        )
        assert_equal location, @geocoder.locate('1600 Amphitheatre Parkway, Mountain View, CA')
      end
      

      # The #locate parameters are broad, so the XML response contains 
      # multiple results at street-level precision. We expect to get the 
      # first result back, and it should not contain a postal code.
      def test_success_multiple_results
        return unless prepare_response(:success_multiple_results)

        location = Location.new(
          :street => "Queen St W",
          :locality => "Toronto",
          :region => "ON",
          :postal_code => nil,
          :country => "CA",
          :longitude => -79.4125590,
          :latitude => 43.6455030,
          :precision => :street
        )
        assert_equal location, @geocoder.locate('Queen St West, Toronto, ON CA')
      end


        # <?xml version='1.0' encoding='UTF-8'?><kml xmlns='http://earth.google.com/kml/2.0'><Response><name>15-17 </name><Status><code>200</code><request>geocode</request></Status><Placemark id='p1'><Point><coordinates>-17.000000,15.000000,0</coordinates></Point></Placemark></Response></kml>
        def test_only_coordinates
          return unless prepare_response(:only_coordinates)

          location = Location.new(:longitude => -17.000000, :latitude => 15.000000)
          assert_equal location, @geocoder.locate('15-17 & 16 Railroad Square, Nashua, NH, 03064')
        end
        


      def test_partial
        return unless prepare_response(:partial)
        
        location = Location.new(
          :locality => "San Francisco",
          :region => "CA",
          :country => "US",
          :longitude => -122.418333,
          :latitude => 37.775000,
          :precision => :city
        )
        
        assert_equal location, @geocoder.locate('sf ca')
      end
    
      def test_bad_key
        return unless prepare_response(:badkey)
        assert_raises(CredentialsError) { @geocoder.locate('x') }
      end
    
      def test_locate_missing_address
        return unless prepare_response(:missing_address)
        assert_raises(AddressError) { @geocoder.locate 'x' }
      end
    
      def test_locate_server_error
        return unless prepare_response(:server_error)
        assert_raises(Error) { @geocoder.locate 'x' }
      end

      def test_locate_too_many_queries
        return unless prepare_response(:limit)
        assert_raises(CredentialsError) { @geocoder.locate 'x' }
      end

      def test_locate_unavailable_address
        return unless prepare_response(:unavailable)
        assert_raises(AddressError) { @geocoder.locate 'x' }
      end

      def test_locate_unknown_address
        return unless prepare_response(:unknown_address)
        assert_raises(AddressError) { @geocoder.locate 'x' }
      end

    protected

      def prepare_response(id = :success)
        URI::HTTP.responses << response('google', id)
      end
  
    end
  end
end