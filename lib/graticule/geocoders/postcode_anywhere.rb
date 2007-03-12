module Graticule #:nodoc:

  class PostcodeAnywhereGeocoder < RestGeocoder

    # http://www.postcodeanywhere.com/register/
    def initialize(account_code, license_code)
      @url = URI.parse 'http://services.postcodeanywhere.co.uk/xml.aspx'
      @account_code = account_code
      @license_code = license_code
    end

    def locate(address)
      get :origin => address, :destination => address
    end

    def make_url(params) #:nodoc:
      params[:account_code] = @account_code
      params[:license_code] = @license_code
      params[:action] = 'nearest'
      super params
    end

    def parse_response(xml) #:nodoc:
      result = xml.elements['/PostcodeAnywhere/Data/Item[1]']
      returning Location.new do |location|
        location.latitude = result.attribute('latitude').value.to_f
        location.longitude = result.attribute('longitude').value.to_f
        location.postal_code = result.attribute('origin_postcode').value
      end
    end

    # http://www.postcodeanywhere.co.uk/developers/documentation/errors.aspx
    def check_error(xml) #:nodoc:
      #raise AddressError, xml.text if xml.text == 'couldn\'t find this address! sorry'
      error = xml.elements['/PostcodeAnywhere/Data/Item[@error_number][1]']
      if error
        error_number = error.attribute('error_number').value.to_i
        message = error.attribute('message').value
        if (1..11).include?(error_number) || (34..38).include?(error_number)
          raise CredentialsError, message
        else
          raise Error, message
        end
      end
    end
    
  end
end