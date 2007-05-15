
module Graticule
  module Geocoder

    # Library for looking up coordinates with MetaCarta's GeoParser API.
    #
    # http://labs.metacarta.com/GeoParser/documentation.html
    class MetaCarta < Rest

      def initialize # :nodoc:
        @url = URI.parse 'http://labs.metacarta.com/GeoParser/'
      end

      # Finds +location+ and returns a Location object.
      def locate(location)
        get :q => location.is_a?(String) ? location : location_from_params(location).to_s, :output => 'locations'
      end
      
    private

      def check_error(xml) # :nodoc:
        raise AddressError, 'bad location' unless xml.elements['Locations/Location']
      end

      def parse_response(xml) # :nodoc:
        result = xml.elements['/Locations/Location[1]']
        coords = result.elements['Centroid/gml:Point/gml:coordinates'].text.split ','
        Location.new :latitude => coords.first.to_f, :longitude => coords.last.to_f
      end
      
    end
  end
end