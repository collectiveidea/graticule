require 'test_helper'

module Graticule
  module Geocoder
    class GeonamesTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Geonames.new
      end

      def test_time_zone
        return unless prepare_response(:success)
        
        chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
        assert_equal 'America/Chicago', @geocoder.time_zone(chicago)
      end

      def test_time_zone
        URI::HTTP.uris = []
        URI::HTTP.responses = []
        URI::HTTP.responses << response('geonames', :success)
        chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
        assert_equal 'America/Chicago', @geocoder.time_zone(chicago)
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
        URI::HTTP.responses << response('geonames', id)
      end
  
    end
  end
end