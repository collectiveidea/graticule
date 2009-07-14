module Graticule #:nodoc:
  module Geocoder #:nodoc:

    class Mapquest < Rest 

      PRECISION = {
        'L1' => :address,
        'I1' => :street,
        'B1' => :street,
        'B2' => :street,
        'B3' => :street,
        'Z3' => :zip,
        'Z4' => :zip,
        'Z2' => :zip,
        'Z1' => :zip,
        'A5' => :city,
        'A4' => :county,
        'A3' => :state,
        'A1' => :country
      }

      def initialize(key)
        @key = key
        @url = URI.parse('http://geocode.web.mapquest.com/mq/mqserver.dll')
      end

      # Locates +address+ returning a Location
      def locate(address)
        get :q => address.is_a?(String) ? address : location_from_params(address).to_s
      end

      protected

      def make_url(params) #:nodoc
        query = 'e=5'
        query += '&<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>'
        query += '<Geocode Version="1"><Address>'
        query += '<Street>217 Union St., 11231</Street>'
        query += '</Address><GeocodeOptionsCollection Count="0"/>'
        query += '<Authentication Version="2"><Password>9ASwEx7V</Password><ClientId>6713</ClientId></Authentication>'
        query += '</Geocode>'
        url = @url.dup
        url.query = URI.escape(query)
        url
      end

      # Extracts a location from +xml+.
      def parse_response(xml) #:nodoc:
        longitude = xml.elements['/GeocodeResponse/LocationCollection/GeoAddress/LatLng/Lng'].text.to_f
        latitude = xml.elements['/GeocodeResponse/LocationCollection/GeoAddress/LatLng/Lat'].text.to_f
        returning Location.new(:latitude => latitude, :longitude => longitude) do |l|
          address = REXML::XPath.first(xml, '/GeocodeResponse/LocationCollection/GeoAddress')

          if address
            l.street = value(address.elements['./Street/text()'])
            l.locality = value(address.elements['./AdminArea5/text()'])
            l.region = value(address.elements['./AdminArea3/text()'])
            l.postal_code = value(address.elements['./PostalCode/text()'])
            l.country = value(address.elements['./AdminArea1/text()'])
            l.precision = PRECISION[value(address.elements['./ResultCode/text()'])[0,2]]
          end
        end
      end

      # Extracts and raises any errors in +xml+
      def check_error(xml) #:nodoc
      end

      def value(element)
        element.value if element
      end
    end
  end
end
