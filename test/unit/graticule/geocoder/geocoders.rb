require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')


module Graticule
  
  # Generic tests for all geocoders (theoretically)
  module GeocodersTestCase
    
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

  end
end
