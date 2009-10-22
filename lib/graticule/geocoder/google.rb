module Graticule #:nodoc:
  module Geocoder #:nodoc:
  
    # First you need a Google Maps API key.  You can register for one here:
    # http://www.google.com/apis/maps/signup.html
    # 
    #   gg = Graticule.service(:google).new(MAPS_API_KEY)
    #   location = gg.locate '1600 Amphitheater Pkwy, Mountain View, CA'
    #   p location.coordinates
    #   #=> [37.423111, -122.081783
    #
    class Google < Base
      # http://www.google.com/apis/maps/documentation/#Geocoding_HTTP_Request
    
      # http://www.google.com/apis/maps/documentation/reference.html#GGeoAddressAccuracy
      PRECISION = {
        0 => :unknown,      # Unknown location.
        1 => :country,      # Country level accuracy.
        2 => :region,       # Region (state, province, prefecture, etc.) level accuracy.
        3 => :region,       # Sub-region (county, municipality, etc.) level accuracy.
        4 => :locality,     # Town (city, village) level accuracy.
        5 => :postal_code,  # Post code (zip code) level accuracy.
        6 => :street,       # Street level accuracy.
        7 => :street,       # Intersection level accuracy.
        8 => :address,      # Address level accuracy.
        9 => :premise       # Premise (building name, property name, shopping center, etc.) level accuracy.
      }

      def initialize(key)
        @key = key
        @url = URI.parse 'http://maps.google.com/maps/geo'
      end

      # Locates +address+ returning a Location
      def locate(address)
        get :q => address.is_a?(String) ? address : location_from_params(address).to_s
      end

    private
      class Address
        include HappyMapper
        tag 'AddressDetails'
        namespace 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'

        attribute :accuracy, Integer, :tag => 'Accuracy'
      end
    
      class Placemark
        include HappyMapper
        tag 'Placemark'
        element :coordinates, String, :deep => true
        has_one :address, Address
      
        attr_reader :longitude, :latitude
        delegate :accuracy, :to => :address, :allow_nil => true
        
        with_options :deep => true, :namespace => 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0' do |map|
          map.element :street,      String, :tag => 'ThoroughfareName'
          map.element :locality,    String, :tag => 'LocalityName'
          map.element :region,      String, :tag => 'AdministrativeAreaName'
          map.element :postal_code, String, :tag => 'PostalCodeNumber'
          map.element :country,     String, :tag => 'CountryNameCode'
        end
      
        def coordinates=(coordinates)
          @longitude, @latitude, _ = coordinates.split(',').map { |v| v.to_f }
        end
      
        def precision
          PRECISION[accuracy] || :unknown
        end
      end
    
      class Response
        include HappyMapper
        tag 'Response'
        element :code, Integer, :tag => 'code', :deep => true
        has_many :placemarks, Placemark
      end
      
      def prepare_response(xml)
        Response.parse(xml, :single => true)
      end

      def parse_response(response) #:nodoc:
        result = response.placemarks.first
        Location.new(
          :latitude    => result.latitude,
          :longitude   => result.longitude,
          :street      => result.street,
          :locality    => result.locality,
          :region      => result.region,
          :postal_code => result.postal_code,
          :country     => result.country,
          :precision   => result.precision
        )
      end

      # Extracts and raises an error from +xml+, if any.
      def check_error(response) #:nodoc:
        case response.code
        when 200 then # ignore, ok
        when 500 then
          raise Error, 'server error'
        when 601 then
          raise AddressError, 'missing address'
        when 602 then
          raise AddressError, 'unknown address'
        when 603 then
          raise AddressError, 'unavailable address'
        when 610 then
          raise CredentialsError, 'invalid key'
        when 620 then
          raise CredentialsError, 'too many queries'
        else
          raise Error, "unknown error #{response.code}"
        end
      end

      # Creates a URL from the Hash +params+.
      # sets the output type to 'xml'.
      def make_url(params) #:nodoc:
        super params.merge(:key => @key, :oe => 'utf8', :output => 'xml', :sensor => false)
      end
    end
  end
end