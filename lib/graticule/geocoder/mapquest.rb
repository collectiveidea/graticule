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
    class Mapquest < Base 
      # I would link to the documentation here, but there is none that will do anything but confuse you.

      PRECISION = {
        'L1' => :address,
        'I1' => :street,
        'B1' => :street,
        'B2' => :street,
        'B3' => :street,
        'Z3' => :postal_code,
        'Z4' => :postal_code,
        'Z2' => :postal_code,
        'Z1' => :postal_code,
        'A5' => :locality,
        'A4' => :region,
        'A3' => :region,
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
      
      class Address
        include HappyMapper
        tag 'GeoAddress'
        element :latitude, Float, :tag => 'Lat', :deep => true
        element :longitude, Float, :tag => 'Lng', :deep => true
        element :street, String, :tag => 'Street'
        element :locality, String, :tag => 'AdminArea5'
        element :region, String, :tag => 'AdminArea3'
        element :postal_code, String, :tag => 'PostalCode'
        element :country, String, :tag => 'AdminArea1'
        element :result_code, String, :tag => 'ResultCode'
        
        def precision
          PRECISION[result_code.to_s[0,2]] || :unknown
        end
      end
      
      class Result
        include HappyMapper
        tag 'GeocodeResponse'
        has_many :addresses, Address, :deep => true
      end
      
      def prepare_response(xml)
        Result.parse(xml, :single => true)
      end

      # Extracts a location from +xml+.
      def parse_response(result) #:nodoc:
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

      # Extracts and raises any errors in +xml+
      def check_error(xml) #:nodoc
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
