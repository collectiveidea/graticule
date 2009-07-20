module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # A library for lookup up coordinates with geocoder.us' API.
    #
    # http://geocoder.us/help/
    class GeocoderUs < Rest

      # Creates a new GeocoderUs object optionally using +username+ and
      # +password+.
      #
      # You can sign up for a geocoder.us account here:
      #
      # http://geocoder.us/user/signup
      def initialize(user = nil, password = nil)
        if user and password then
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

      def parse_response(xml) #:nodoc:
        location = Location.new
        location.street = xml.elements['rdf:RDF/geo:Point/dc:description'].text

        location.latitude = xml.elements['rdf:RDF/geo:Point/geo:lat'].text.to_f
        location.longitude = xml.elements['rdf:RDF/geo:Point/geo:long'].text.to_f

        return location
      end

      def check_error(xml) #:nodoc:
        text = xml.to_s
        raise AddressError, text if text =~ /couldn't find this address! sorry/
        raise Error, text if text =~ /Your browser sent a request that this server could not understand./
        raise Error, text if !(text =~ /geo:Point/)
      end

    end
  end
end