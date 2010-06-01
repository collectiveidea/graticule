module Graticule #:nodoc:
  module Geocoder #:nodoc:
    class Geonames < Base
      
      def initialize
        @url = URI.parse 'http://ws.geonames.org/timezone'
      end
      
      def time_zone(location)
        get :formatted => 'true', :style => 'full', :lat => location.latitude, :lng => location.longitude        
      end
      
    private 
      class Status
        include HappyMapper
        tag 'status'
        attribute :message, String
        attribute :value, String
      end
      
      class Response
        include HappyMapper
        tag 'geonames'
        element :timezoneId, String, :deep => true
        has_one :status, Status
      end
      
      def prepare_response(xml)
        Response.parse(xml, :single => true)
      end

      def parse_response(response) #:nodoc:
        response.timezoneId
      end
      
      # Extracts and raises an error from +xml+, if any.
      def check_error(response) #:nodoc:
        if response && response.status
          case response.status.value
          when 14 then
            raise Error, reponse.status.message
          when 12 then
            raise AddressError, reponse.status.message
          else
            raise Error, "unknown error #{response.status.message}"
          end
        end
      end
    end
  end
end
