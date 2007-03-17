require 'yaml'

module Graticule #:nodoc:
  module Geocoder #:nodoc:

    class HostIp

      def initialize
        @url = URI.parse 'http://api.hostip.info/get_html.php'
      end

      # Geocode an IP address using http://hostip.info
      def locate(address)
        make_url(:ip => address, :position => true).open do |response|
          # add new line so YAML.load doesn't puke
          result = response.read + "\n"
          check_error(result)
          parse_response(YAML.load(result))
        end
      end
    
    private
      
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
        raise AddressError, 'Unknown' if response =~ /Unknown City/
        raise AddressError, 'Private Address' if response =~ /Private Address/
      end

      def make_url(params) #:nodoc:
        returning @url.dup do |url|
          url.query = params.map do |k,v| 
            "#{URI.escape k.to_s}=#{URI.escape v.to_s}"
          end.join('&')
        end
      end


    end
  end
end