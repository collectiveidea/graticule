module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # A library for lookup of coordinates with http://geo.localsearchmaps.com/
    #
    # See http://emad.fano.us/blog/?p=277
    class LocalSearchMaps < Base
    
      def initialize
        @url = URI.parse 'http://geo.localsearchmaps.com/'
      end
    
      # This web service will handle some addresses outside the US
      # if given more structured arguments than just a string address
      # So allow input as a hash for the different arguments (:city, :country, :zip)
      def locate(params)
        get params.is_a?(String) ? {:loc => params} : map_attributes(location_from_params(params))
      end
      
    private
    
      def map_attributes(location)
        mapping = {:street => :street, :locality => :city, :region => :state, :postal_code => :zip, :country => :country}
        mapping.keys.inject({}) do |result,attribute|
          result[mapping[attribute]] = location.attributes[attribute] unless location.attributes[attribute].blank?
          result
        end
      end
    
      def check_error(js)
        raise AddressError, "Empty Response" if js.nil?
        raise AddressError, 'Location not found' if js =~ /location not found/
      end
    
      def parse_response(js)
        returning Location.new do |location|
          coordinates = js.match(/map.centerAndZoom\(new GPoint\((.+?), (.+?)\)/)
          location.longitude = coordinates[1].to_f
          location.latitude = coordinates[2].to_f
        end
      end
      
    end
  end
end
