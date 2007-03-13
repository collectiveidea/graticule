module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # A library for lookup of coordinates with http://geo.localsearchmaps.com/
    class LocalSearchMaps < Rest
    
      def initialize
        @url = URI.parse 'http://geo.localsearchmaps.com/'
      end
    
      # This web service will handle some addresses outside the US
      # if given more structured arguments than just a string address
      # So allow input as a hash for the different arguments (:city, :country, :zip)
      def locate(address, args = {})
        if args.empty?
          get :address => address
        else
          get args.merge(:street => address)
        end
      end
    
      def check_error(js)
        raise AddressError, "Empty Response" if js.nil? or js.text.nil?
        raise AddressError, 'Location not found' if js.text =~ /location not found/
      end
    
      def parse_response(js)
        returning Location.new do |location|
          coordinates = js.text.match(/map.centerAndZoom\(new GPoint\((.+?), (.+?)\)/)
          location.longitude = coordinates[1]
          location.latitude = coordinates[2]
        end
      end
      
    end
  end
end
