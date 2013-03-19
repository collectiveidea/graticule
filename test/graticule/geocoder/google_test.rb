# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class GoogleTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Google.new('APP_ID')
      end

      def test_success
        return unless prepare_response(:success)
        location = Location.new(
          :latitude=>37.421641,
          :longitude=>-122.0855016,
          :street=>"1600 Amphitheatre Pkwy",
          :locality=>"Mountain View",
          :region=>"CA",
          :postal_code=>"94043",
          :country=>"US",
          :precision=>:address
        )
        assert_equal location, @geocoder.locate('1600 Amphitheatre Parkway, Mountain View, CA')
      end

      # The #locate parameters are broad, so the JSON response contains
      # multiple results at street-level precision. We expect to get the
      # first result back, and it should not contain a postal code.
      def test_success_multiple_results
        return unless prepare_response(:success_multiple_results)
        location = Location.new(
          :latitude=>43.645337, 
          :longitude=>-79.413208, 
          :street=>"Queen St W", 
          :locality=>"Toronto", 
          :region=>"ON", 
          :country=>"CA", 
          :precision=>:street
        )
        assert_equal location, @geocoder.locate('Queen St West, Toronto, ON CA')
      end

      def test_partial
        return unless prepare_response(:partial)

        location = Location.new(
          :latitude=>37.7749295, 
          :longitude=>-122.4194155, 
          :locality=>"San Francisco", 
          :region=>"CA", 
          :country=>"US", 
          :precision=>:locality
        )
        assert_equal location, @geocoder.locate('sf ca')
      end

      def test_locate_server_error
        return unless prepare_response(:server_error)
        assert_raises(Error) { @geocoder.locate 'x' }
      end

      def test_locate_too_many_queries
        return unless prepare_response(:limit)
        assert_raises(CredentialsError) { @geocoder.locate 'x' }
      end

      def test_locate_zero_results
        return unless prepare_response(:zero_results)
        assert_raises(AddressError) { @geocoder.locate 'x' }
      end

      def test_bad_key
        return unless prepare_response(:badkey)
        assert_raises(CredentialsError) { @geocoder.locate('x') }
      end

    protected

      def prepare_response(id = :success)
        URI::HTTP.responses << response('google', id, 'json')
      end

    end
  end
end