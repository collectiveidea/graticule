require 'httparty'

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
    class Google < Rest 
      include HTTParty
      base_uri 'maps.google.com'
      default_params :output => :xml
      format :xml
      
      # http://www.google.com/apis/maps/documentation/#Geocoding_HTTP_Request
    
      # http://www.google.com/apis/maps/documentation/reference.html#GGeoAddressAccuracy
      PRECISION = {
        0 => :unknown,      # Unknown location. (Since 2.59)
        1 => :country,      # Country level accuracy. (Since 2.59)
        2 => :state,        # Region (state, province, prefecture, etc.) level accuracy. (Since 2.59)
        3 => :state,        # Sub-region (county, municipality, etc.) level accuracy. (Since 2.59)
        4 => :city,         # Town (city, village) level accuracy. (Since 2.59)
        5 => :zip,          # Post code (zip code) level accuracy. (Since 2.59)
        6 => :street,       # Street level accuracy. (Since 2.59)
        7 => :street,       # Intersection level accuracy. (Since 2.59)
        8 => :address       # Address level accuracy. (Since 2.59)
      }

      # Creates a new GoogleGeocode that will use Google Maps API +key+.
      def initialize(key)
        @key = key
      end

      def locate(address)
        q = address.is_a?(String) ? address : location_from_params(address).to_s
        parse_response self.class.get('/maps/geo', :query => {:q => q, :key => @key})
      end

    private

      # Extracts a Location from +xml+.
      def parse_response(result) #:nodoc:
        address = result.flatten
        check_error(address)
        longitude, latitude, = address['coordinates'].split(',').map { |v| v.to_f }
        returning Location.new(:latitude => latitude, :longitude => longitude) do |l|
          l.street = address['ThoroughfareName']
          l.locality = address['ThoroughfareName']
          l.region = address['AdministrativeAreaName']
          l.postal_code = address['PostalCodeNumber']
          l.country = address['CountryNameCode']
          l.precision = PRECISION[address['Accuracy'].to_i] || :unknown
        end
      end

      # Extracts and raises an error from +xml+, if any.
      def check_error(result) #:nodoc:
        case result['code'].to_i
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
          raise Error, "unknown error #{status}"
        end
      end
    end
  end
end