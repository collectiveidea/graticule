module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # Multimap geocoding API
    
    class Multimap < Base
      
      # This precision information is not complete.
      # More details should be implemented from:
      # http://www.multimap.com/share/documentation/clientzone/gqcodes.htm
      
      PRECISION = {
        6 => :country,
        5 => :state,
        4 => :postal_code,
        3 => :city,
        2 => :street,
        1 => :address
      }
      
      # Web services initializer.
      #
      # The +api_key+ is the Open API key that uniquely identifies your
      # application.
      #
      # See http://www.multimap.com/openapi/
      
      def initialize(api_key)
        @api_key = api_key
        @url = URI.parse "http://clients.multimap.com/API/geocode/1.2/#{@api_key}"
      end
      
      # Returns a location for an address in the form of a String, Hash or Location.
      
      def locate(address)
        location = address.is_a?(String) ? address : location_from_params(address)
        case location
        when String
          get :qs => location
        when Location
          get "street" => location.street, 
              "region" => location.region, 
              "city" => location.city, 
              "postalCode" => location.postal_code, 
              "countryCode" => location.country
        end
      end
      
      class Address
        include HappyMapper
        tag 'Location'
        
        attribute :quality, Integer, :tag => 'geocodeQuality'
        element :street, String, :tag => 'Street', :deep => true
        element :locality, String, :tag => 'Area', :deep => true
        element :region, String, :tag => 'State', :deep => true
        element :postal_code, String, :tag => 'PostalCode', :deep => true
        element :country, String, :tag => 'CountryCode', :deep => true
        element :latitude, Float, :tag => 'Lat', :deep => true
        element :longitude, Float, :tag => 'Lon', :deep => true
        
        def precision
          PRECISION[quality] || :unknown
        end
      end
      
      class Result
        include HappyMapper
        tag 'Results'
        attribute :error, String, :tag => 'errorCode'
        has_many :addresses, Address
      end
      
      def prepare_response(xml)
        Result.parse(xml, :single => true)
      end
      
      def parse_response(result)
        addr = result.addresses.first
        Location.new(
          :latitude    => addr.latitude,
          :longitude   => addr.longitude,
          :street      => addr.street,
          :locality    => addr.locality,
          :region      => addr.region,
          :postal_code => addr.postal_code,
          :country     => addr.country,
          :precision   => addr.precision
        )
      end
      
      def check_error(result)
        raise Error, result.error unless result.error.blank?
      end
      
    end
  end
end