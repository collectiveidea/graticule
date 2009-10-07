require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class GeonamesTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Geonames.new
      end
      
      def test_success
        return unless prepare_response(:success)
        
        location = Location.new(
          :street => "1600 Amphitheatre Pkwy",
          :locality => "Mountain View",
          :region => "CA",
          :postal_code => "94043",
          :country => "US",
          :longitude => -122.0850350,
          :latitude => 37.4231390,
          :precision => :address
        )
        assert_equal location, @geocoder.locate('1600 Amphitheatre Parkway, Mountain View, CA')
      end
      
      
      def test_only_coordinates
        return unless prepare_response(:only_coordinates)
        
        location = Location.new(:longitude => -17.000000, :latitude => 15.000000)
        assert_equal location, @geocoder.locate('15-17 & 16 Railroad Square, Nashua, NH, 03064')
      end
      
    
      # def test_locate_server_error
      #   return unless prepare_response(:server_error)
      #   assert_raises(Error) { @geocoder.locate 'x' }
      # end
      # 
      # def test_locate_too_many_queries
      #   return unless prepare_response(:limit)
      #   assert_raises(CredentialsError) { @geocoder.locate 'x' }
      # end
      # 
      # def test_locate_unavailable_address
      #   return unless prepare_response(:unavailable)
      #   assert_raises(AddressError) { @geocoder.locate 'x' }
      # end
      # 
      # def test_locate_unknown_address
      #   return unless prepare_response(:unknown_address)
      #   assert_raises(AddressError) { @geocoder.locate 'x' }
      # end

    protected

      def prepare_response(id = :success)
        URI::HTTP.responses << response('google', id)
      end
  
    end
  end
end