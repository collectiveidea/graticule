require File.dirname(__FILE__) + '/../../test_helper'

module Geocode
  class GeocodersTest < Test::Unit::TestCase

    GEOCODERS = {:google => {:key => 'APP_ID'}}
  
    def setup
      URI::HTTP.responses = []
      URI::HTTP.uris = []
      
      @geocoders = {}
      GEOCODERS.each do |geocoder,params|
        @geocoders[geocoder] = Geocode.service(geocoder).new(params)
      end
    end
    
    def test_success
      @geocoders.each do |name,geocoder|
        URI::HTTP.responses << response(name, :success)
        
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
        assert_equal location, geocoder.locate('1600 Amphitheatre Parkway, Mountain View, CA')
        assert URI::HTTP.responses.empty?
        assert_equal 1, URI::HTTP.uris.length
        assert_equal 'http://maps.google.com/maps/geo?key=APP_ID&output=xml&q=1600%20Amphitheatre%20Parkway,%20Mountain%20View,%20CA', URI::HTTP.uris.first
      end
    end
    
    def test_bad_key
      @geocoders.each do |name,geocoder|
        URI::HTTP.responses << response(name, :badkey)
        begin
          geocoder.locate('x')
        rescue Geocode::CredentialsError => e
          assert_equal 'invalid key', e.message
        else
          flunk 'Error expected'
        end
      end
    end
    
    def test_locate_missing_address
      @geocoders.each do |name,geocoder|
        URI::HTTP.responses << response(name, :missing_address)
        begin
          geocoder.locate 'x'
        rescue Geocode::AddressError => e
          assert_equal 'missing address', e.message
        else
          flunk 'Error expected'
        end
      end
    end
    
    def test_locate_server_error
      @geocoders.each do |name,geocoder|
        URI::HTTP.responses << response(name, :server_error)
        begin
          geocoder.locate 'x'
        rescue Geocode::Error => e
          assert_equal 'server error', e.message
        else
          flunk 'Error expected'
        end
      end
    end

    def test_locate_too_many_queries
      @geocoders.each do |name,geocoder|
        URI::HTTP.responses << response(name, :limit)
        begin
          geocoder.locate 'x'
        rescue Geocode::CredentialsError => e
          assert_equal 'too many queries', e.message
        else
          flunk 'Error expected'
        end
      end
    end

    def test_locate_unavailable_address
      @geocoders.each do |name,geocoder|
        URI::HTTP.responses << response(name, :unavailable)
        begin
          geocoder.locate 'x'
        rescue Geocode::AddressError => e
          assert_equal 'unavailable address', e.message
        else
          flunk 'Error expected'
        end
      end
    end

    def test_locate_unknown_address
      @geocoders.each do |name,geocoder|
        URI::HTTP.responses << response(name, :unknown)
        begin
          geocoder.locate 'x'
        rescue Geocode::AddressError => e
          assert_equal 'unknown address', e.message
        else
          flunk 'Error expected'
        end
      end
    end
  end
end
