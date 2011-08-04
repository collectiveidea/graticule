# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class FreeThePostcodeTest < Test::Unit::TestCase

      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = FreeThePostcode.new
      end

      def test_success
        return unless prepare_response(:success)

        location = Location.new(
          :latitude => 51.503172,
          :longitude => -0.241641)

        assert_equal location, @geocoder.locate('W1A 1AA')
      end

      def test_locate_unknown_address
        return unless prepare_response(:not_found)
        assert_raises(AddressError) { @geocoder.locate 'Z12 9pp' }
      end

    protected

      def prepare_response(id = :success)
        URI::HTTP.responses << response('freethepostcode', id, 'txt')
      end

    end
  end
end
