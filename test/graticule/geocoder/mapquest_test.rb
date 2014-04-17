# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class MapquestTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
      end

      def test_success
        @geocoder = Mapquest.new('api_key')
        prepare_response(:success)
        location = Location.new(
          :country => "US",
          :latitude => 44.15175,
          :locality => "Lovell",
          :longitude => -70.893,
          :postal_code => "04051-3919",
          :precision => :point,
          :region => "ME",
          :street => "44 Allen Rd"
        )
        assert_equal(location, @geocoder.locate('44 Allen Rd., Lovell, ME 04051'))
      end

      def test_multi_result
        @geocoder = Mapquest.new('api_key')
        prepare_response(:multi_result)
        location = Location.new(
          :country => "US",
          :latitude => 40.925598,
          :locality => "Stony Brook",
          :longitude => -73.141403,
          :postal_code => nil,
          :precision => :locality,
          :region => "NY",
          :street => nil
        )
        assert_equal(location, @geocoder.locate('217 Union St., NY'))
      end

      def test_multi_country
        @geocoder = Mapquest.new('api_key', false, 'US')
        prepare_response(:multi_country_success)
        location = Location.new(
            :country => "US",
            :latitude => 30.280046,
            :locality => "",
            :longitude => -90.786583,
            :postal_code => "12345",
            :precision => :postal_code,
            :region => "LA",
            :street => nil
        )
        assert_equal(location, @geocoder.locate('12345 us'))
      end

      def test_query_construction
        request = Mapquest::Request.new("217 Union St., NY", "api_key")
        query = %Q{key=api_key&outFormat=xml&inFormat=kvp&location=217%20Union%20St.,%20NY}
        assert_equal(query, request.query)
      end

      protected

      def prepare_response(id)
        URI::HTTP.responses << response('mapquest', id)
      end
    end
  end
end
