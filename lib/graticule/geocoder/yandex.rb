# encoding: UTF-8
module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # First you need a Yandex Maps API key.  You can register for one here:
    # http://api.yandex.ru/maps/form.xml
    #
    #   gg = Graticule.service(:yandex).new(MAPS_API_KEY)
    #   location = gg.locate 'Россия, Москва, ул. Моховая, д.18'
    #   p location.coordinates
    #   #=> [37.612281, 55.753342]
    #
    class Yandex < Base
      # http://api.yandex.ru/maps/geocoder/doc/desc/concepts/input_params.xml
      # http://api.yandex.ru/maps/geocoder/doc/desc/concepts/response_structure.xml

      PRECISION = {
        :country  => Precision::Country,      # Country level accuracy.
        :province => Precision::Region,       # Region (state, province, prefecture, etc.) level accuracy.
        :area     => Precision::Region,       # Sub-region (county, municipality, etc.) level accuracy.
        :locality => Precision::Locality,     # Town (city, village) level accuracy.
        :metro    => Precision::Street,       # Street level accuracy.
        :street   => Precision::Street,       # Intersection level accuracy.
        :house    => Precision::Address,      # Address level accuracy.
      }.stringify_keys

      def initialize(key)
        @key = key
        @url = URI.parse 'http://geocode-maps.yandex.ru/1.x/'
      end

      # Locates +address+ returning a Location
      def locate(address)
        get :geocode => address.is_a?(String) ? address : location_from_params(address).to_s
      end

    private

      class GeocoderMetaData
        include HappyMapper

        tag 'GeocoderMetaData'
        namespace 'http://maps.yandex.ru/geocoder/1.x'

        element :kind, String, :tag => 'kind'
      end

      class FeatureMember
        include HappyMapper

        tag 'featureMember'
        namespace 'http://www.opengis.net/gml'

        has_one :geocoder_meta_data, GeocoderMetaData

        attr_reader :longitude, :latitude

        element :coordinates, String, :tag => 'pos', :deep => true

        with_options :deep => true, :namespace => 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0' do |map|
          map.element :street,      String, :tag => 'ThoroughfareName'
          map.element :locality,    String, :tag => 'LocalityName'
          map.element :region,      String, :tag => 'AdministrativeAreaName'
          map.element :postal_code, String, :tag => 'PostalCodeNumber'
          map.element :country,     String, :tag => 'CountryNameCode'
        end

        def coordinates=(coordinates)
          @longitude, @latitude = coordinates.split(' ').map { |v| v.to_f }
        end

        def precision
          PRECISION[geocoder_meta_data.kind] || :unknown
        end
      end

      class Error
        include HappyMapper

        tag 'error'
        element :status, Integer, :tag => 'status'
        element :message, String, :tag => 'message'
      end

      class Response
        include HappyMapper

        tag 'GeoObjectCollection'
        has_many :feature_members, FeatureMember

        def status
          200
        end
      end

      def prepare_response(xml)
        Response.parse(xml, :single => true) || Error.parse(xml, :single => true)
      end

      def parse_response(response) #:nodoc:
        result = response.feature_members.first
        Location.new(
          :latitude    => result.latitude,
          :longitude   => result.longitude,
          :street      => result.street,
          :locality    => result.locality,
          :country     => result.country,
          :precision   => result.precision
        )
      end

      # Extracts and raises an error from +xml+, if any.
      def check_error(response) #:nodoc:
        case response.status
        when 200 then # ignore, ok
        when 401 then
          raise CredentialsError, response.message
        else
          raise Error, response.message
        end
      end

      # Creates a URL from the Hash +params+.
      # sets the output type to 'xml'.
      def make_url(params) #:nodoc:
        super params.merge(:key => @key)
      end
    end
  end
end

