module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # Mapquest requires both a client id and a password, which you can
    # get by registering at:
    # http://developer.mapquest.com/Home/Register?_devAPISignup_WAR_devAPISignup_action=signup&_devAPISignup_WAR_devAPISignup_clientType=Developer
    #
    # mq = Graticule.service(:mapquest).new(CLIENT_ID, PASSWORD)
    # location = gg.locate('44 Allen Rd., Lovell, ME 04051') 
    # [42.78942, -86.104424]
    #
    class Mapquest < Rest 
      # I would link to the documentation here, but there is none that will do anything but confuse you.

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

      def initialize(client_id, password)
        @password = password
        @client_id = client_id
        @url = URI.parse('http://geocode.dev.mapquest.com/mq/mqserver.dll')
      end

      # Locates +address+ returning a Location
      def locate(address)
        get :q => address.is_a?(String) ? address : location_from_params(address).to_s
      end

      protected

      def make_url(params) #:nodoc
        query = "e=5&<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><Geocode Version=\"1\"> \
          #{address_string(params[:q])}#{authentication_string}</Geocode>"
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

      def authentication_string
        "<Authentication Version=\"2\"><Password>#{@password}</Password><ClientId>#{@client_id}</ClientId></Authentication>"
      end

      def address_string(query)
        "<Address><Street>#{query}</Street></Address><GeocodeOptionsCollection Count=\"0\"/>"
      end
    end
  end
end
