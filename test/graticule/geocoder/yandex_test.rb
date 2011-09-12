# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class YandexTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Yandex.new('APP_ID')
      end

      def test_success
        return unless prepare_response(:success)

        location = Location.new(
          :street => "Моховая улица",
          :locality => "Москва",
          :country => "RU",
          :longitude => 37.612281,
          :latitude => 55.753342, 
          :precision => :address
        )
        assert_equal location, @geocoder.locate('Россия, Москва, ул. Моховая, д.18')
      end

      def test_bad_key
        return unless prepare_response(:badkey)

        assert_raises(CredentialsError) { @geocoder.locate('x') }
      end

    protected

      def prepare_response(id = :success)
        URI::HTTP.responses << response('yandex', id)
      end

    end
  end
end

