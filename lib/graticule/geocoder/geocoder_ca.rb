module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # TODO: Reverse Geocoding
    class GeocoderCa < Rest

      def initialize(auth = nil)
        @url = URI.parse 'http://geocoder.ca/'
        @auth = auth
      end

      def locate(address)
        get :locate => address.is_a?(String) ? address : location_from_params(address).to_s(:country => false)
      end
      
    private
      
      def parse_response(xml) #:nodoc:
        returning Location.new do |location|
          location.latitude = xml.elements['geodata/latt'].text.to_f
          location.longitude = xml.elements['geodata/longt'].text.to_f
          location.street = xml.elements['geodata/standard/staddress'].text
          location.locality = xml.elements['geodata/standard/city'].text
          location.region = xml.elements['geodata/standard/prov'].text
        end
      end

      def check_error(xml) #:nodoc:
        error = xml.elements['geodata/error']
        if error
          code = error.elements['code'].text.to_i
          message = error.elements['description'].text
          if (1..3).include?(code)
            raise CredentialsError, message
          elsif (4..8).include?(code)
            raise AddressError, message
          else
            raise Error, message
          end
        end
      end

      def make_url(params) #:nodoc:
        params[:auth]       = @auth if @auth
        params[:standard]   = 1
        params[:showpostal] = 1
        params[:geoit]      = 'XML'
        super params
      end


    end
  end
end