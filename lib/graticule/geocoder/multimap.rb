module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # Multimap geocoding API
    
    class Multimap < Rest
      
      PRECISION = {
        "4"=> :country,
        "3" => :state,
        "2" => :city,
        "2" => :zip,
        "1" => :address
      }
      
      def initialize(api_key)
        @api_key = api_key
        @url = URI.parse "http://clients.multimap.com/API/geocode/1.2/#{@api_key}"
      end
      
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
      
      def parse_response(xml)
        r = xml.elements['Results/Location[1]']
        returning Location.new do |location|
          
          location.precision = PRECISION[r.attributes['geocodeQuality']] || :unknown
          
          location.street = r.elements['Address/Street'].text.titleize unless r.elements['Address/Street'].nil?
          location.locality = r.elements['Address/Areas/Area'].text.titleize unless r.elements['Address/Areas/Area'].nil?
          location.region = r.elements['Address/State'].text.titleize unless r.elements['Address/State'].nil?
          location.postal_code = r.elements['Address/PostalCode'].text unless r.elements['Address/PostalCode'].nil?
          location.country = r.elements['Address/CountryCode'].text
          
          location.latitude = r.elements['Point/Lat'].text.to_f
          location.longitude = r.elements['Point/Lon'].text.to_f
        end
      end
      
      def check_error(xml)
        error = xml.elements['Results'].attributes['errorCode']
        raise Error, error unless error.nil?
      end
      
    end
  end
end