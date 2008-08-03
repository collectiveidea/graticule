require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class HostIpTest < Test::Unit::TestCase
      
      def setup
        @geocoder = HostIp.new
        URI::HTTP.responses = []
        URI::HTTP.uris = []
      end
      
      def test_success
        prepare_response :success
        
        location = Location.new :country => 'US', :locality => 'Mountain View',
          :region => 'CA', :latitude => 37.402, :longitude => -122.078
        
        assert_equal location, @geocoder.locate('64.233.167.99')
      end
      
      def test_unknown
        prepare_response :unknown
        assert_raises(AddressError) { @geocoder.locate('127.0.0.1') }
      end

      def test_private_ip
        prepare_response :private
        assert_raises(AddressError) { @geocoder.locate('127.0.0.1') }
      end
      
    private
    
      def prepare_response(id = :success)
        URI::HTTP.responses << response('host_ip', id, 'txt')
      end
      
    end
  end
end