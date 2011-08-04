# encoding: UTF-8
module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # A library for lookup up coordinates with geocoder.us' API.
    #
    # http://geocoder.us/help/
    class GeocoderUs < Base

      # Creates a new GeocoderUs object optionally using +username+ and
      # +password+.
      #
      # You can sign up for a geocoder.us account here:
      #
      # http://geocoder.us/user/signup
      def initialize(user = nil, password = nil)
        if user && password
          @url = URI.parse 'http://geocoder.us/member/service/rest/geocode'
          @url.user = user
          @url.password = password
        else
          @url = URI.parse 'http://rpc.geocoder.us/service/rest/geocode'
        end
      end

      # Locates +address+ and returns the address' latitude and longitude or
      # raises an AddressError.
      def locate(address)
        get :address => address.is_a?(String) ? address : location_from_params(address).to_s(:country => false)
      end
      
    private
      class Point
        include HappyMapper
        tag 'Point'
        namespace 'http://www.w3.org/2003/01/geo/wgs84_pos#'
        
        element :description, String, :namespace => 'http://purl.org/dc/elements/1.1/'
        element :longitude,   Float,  :tag => 'long'
        element :latitude,    Float,  :tag => 'lat'
      end

      def parse_response(xml) #:nodoc:
        point = Point.parse(xml, :single => true)
        Location.new(
          :street    => point.description,
          :latitude  => point.latitude,
          :longitude => point.longitude
        )
      end

      def check_error(response) #:nodoc:
        case response
        when /geo:Point/
          # success
        when /couldn't find this address! sorry/
          raise AddressError, response
        else
          raise Error, response
        end
      end

    end
  end
end