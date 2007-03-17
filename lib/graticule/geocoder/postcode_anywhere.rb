module Graticule #:nodoc:
  module Geocoder #:nodoc:

    class PostcodeAnywhere < Rest

      # http://www.postcodeanywhere.com/register/
      def initialize(account_code, license_code)
        @url = URI.parse 'http://services.postcodeanywhere.co.uk/xml.aspx'
        @account_code = account_code
        @license_code = license_code
      end

      def locate(params)
        location = location_from_params(params)
        get :address => location.to_s(:country => false), :country => location.country 
      end
      
    private
    
      def make_url(params) #:nodoc:
        params[:account_code] = @account_code
        params[:license_code] = @license_code
        params[:action] = 'geocode'
        super params
      end

      def parse_response(xml) #:nodoc:
        result = xml.elements['/PostcodeAnywhere/Data/Item[1]']
        returning Location.new do |location|
          location.latitude = result.attribute('latitude').value.to_f
          location.longitude = result.attribute('longitude').value.to_f
          location.street = value(result.attribute('line1'))
          location.locality = value(result.attribute('city'))
          location.region = value(result.attribute('state'))
          location.postal_code = value(result.attribute('postal_code'))
          location.country = value(result.attribute('country'))
        end
      end
      
      def value(attribute)
        attribute.value if attribute
      end

      # http://www.postcodeanywhere.co.uk/developers/documentation/errors.aspx
      def check_error(xml) #:nodoc:
        #raise AddressError, xml.text if xml.text == 'couldn\'t find this address! sorry'
        if error = xml.elements['/PostcodeAnywhere/Data/Item[@error_number][1]']
          error_number = error.attribute('error_number').value.to_i
          message = error.attribute('message').value
          if (1..11).include?(error_number) || (34..38).include?(error_number)
            raise CredentialsError, message
          else
            raise Error, message
          end
        elsif xml.elements['/PostcodeAnywhere/Data'].elements.empty?
          raise AddressError, 'No results returned'
        end
        
      end
    
    end
  end
end