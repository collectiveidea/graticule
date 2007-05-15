require 'yaml'

module Graticule #:nodoc:
  module Geocoder #:nodoc:

    class HostIp < Base

      def initialize
        @url = URI.parse 'http://api.hostip.info/get_html.php'
      end

      # Geocode an IP address using http://hostip.info
      def locate(address)
        get :ip => address, :position => true
      end
    
    private
    
      def prepare_response(response)
        # add new line so YAML.load doesn't puke
        YAML.load(response + "\n")
      end
      
      def parse_response(response) #:nodoc:
        returning Location.new do |location|
          location.latitude = response['Latitude']
          location.longitude = response['Longitude']
          location.locality, location.region = response['City'].split(', ')
          country = response['Country'].match(/\((\w+)\)$/)
          location.country = country[1] if country
        end
      end

      def check_error(response) #:nodoc:
        raise AddressError, 'Unknown' if response['City'] =~ /Unknown City/
        raise AddressError, 'Private Address' if response['City'] =~ /Private Address/
      end

    end
  end
end