require File.dirname(__FILE__) + '/../../../test_helper'

module Geocode
  module GeocodersTestCase # < Test::Unit::TestCase
    
    def test_success
      return unless prepare_response(:success)
      
      location = Location.new(
        :street => "1600 Amphitheatre Pkwy",
        :city => "Mountain View",
        :state => "CA",
        :zip => "94043",
        :country => "US",
        :longitude => -122.083739,
        :latitude => 37.423021,
        :precision => :address
      )
      assert_equal location, @geocoder.locate('1600 Amphitheatre Parkway, Mountain View, CA')
    end
    
    def test_bad_key
      return unless prepare_response(:badkey)
      assert_raises(Geocode::CredentialsError) { @geocoder.locate('x') }
    end
    
    def test_locate_missing_address
      return unless prepare_response(:missing_address)
      assert_raises(Geocode::AddressError) { @geocoder.locate 'x' }
    end
    
    def test_locate_server_error
      return unless prepare_response(:server_error)
      assert_raises(Geocode::Error) { @geocoder.locate 'x' }
    end

    def test_locate_too_many_queries
      return unless prepare_response(:limit)
      assert_raises(Geocode::CredentialsError) { @geocoder.locate 'x' }
    end

    def test_locate_unavailable_address
      return unless prepare_response(:unavailable)
      assert_raises(Geocode::AddressError) { @geocoder.locate 'x' }
    end

    def test_locate_unknown_address
      return unless prepare_response(:unknown_address)
      assert_raises(Geocode::AddressError) { @geocoder.locate 'x' }
    end

  end
end
