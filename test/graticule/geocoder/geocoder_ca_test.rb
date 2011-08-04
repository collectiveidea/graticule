# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class GeocoderCaTest < Test::Unit::TestCase
      
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        
        @geocoder = GeocoderCa.new
        @location = Location.new(
          :latitude => 45.418076,
          :longitude => -75.693293,
          :locality => "ottawa",
          :precision => :unknown,
          :region => "ON",
          :street => "200 MUTCALF  "
        )
      end
      
      def test_success
        prepare_response(:success)
        assert_equal @location, @geocoder.locate('200 mutcalf, ottawa on')
      end
      
      def test_url
        prepare_response(:success)
        @geocoder.locate('200 mutcalf, ottawa on')
        assert_equal 'http://geocoder.ca/?geoit=XML&locate=200%20mutcalf,%20ottawa%20on&showpostal=1&standard=1',
                     URI::HTTP.uris.first
      end

    protected
      def prepare_response(id)
        URI::HTTP.responses << response('geocoder_ca', id)
      end

    end
  end
end