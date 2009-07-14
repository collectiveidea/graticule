require 'open-uri'

module Graticule #:nodoc:
  module Geocoder

    # Abstract class for implementing geocoders.
    #
    # === Example
    #
    # The following methods must be implemented in sublcasses:
    #
    # * +initialize+:: Sets @url to the service enpoint.
    # * +check_error+:: Checks for errors in the server response.
    # * +parse_response+:: Extracts information from the server response.
    #
    # Optionally, you can also override
    #
    # * +prepare_response+:: Convert the string response into a different format
    #   that gets passed on to +check_error+ and +parse_response+.
    #
    # If you have extra URL paramaters (application id, output type) or need to
    # perform URL customization, override +make_url+.
    #
    #   class FakeGeocoder < Base
    #   
    #     def initialize(appid)
    #       @appid = appid
    #       @url = URI.parse 'http://example.com/test'
    #     end
    #
    #     def locate(query)
    #       get :q => query
    #     end
    #   
    #   private
    #   
    #     def check_error(xml)
    #       raise Error, xml.elements['error'].text if xml.elements['error']
    #     end
    #   
    #     def make_url(params)
    #       params[:appid] = @appid
    #       super params
    #     end
    #   
    #     def parse_response(response)
    #       # return Location
    #     end
    #   
    #   end
    #
    class Base
      USER_AGENT = "Mozilla/5.0 (compatible; Graticule/#{Graticule::Version::STRING}; http://graticule.rubyforge.org)"

      def initialize
        raise NotImplementedError
      end
      
    private
    
      def location_from_params(params)
        case params
        when Location then params
        when Hash then Location.new params
        else
          raise ArgumentError, "Expected a Graticule::Location or a hash with :street, :locality, :region, :postal_code, and :country attributes"
        end
      end

      # Check for errors in +response+ and raise appropriate error, if any.
      # Must return if no error could be found.
      def check_error(response)
        raise NotImplementedError
      end

      # Performs a GET request with +params+.  Calls +check_error+ and returns
      # the result of +parse_response+.
      def get(params = {})
        response = prepare_response(make_url(params).open('User-Agent' => USER_AGENT).read)
        check_error(response)
        return parse_response(response)
      rescue OpenURI::HTTPError => e
        check_error(prepare_response(e.io.read))
        raise
      end

      # Creates a URI from the Hash +params+.  Override this then call super if
      # you need to add extra params like an application id or output type.
      def make_url(params)
        escaped_params = params.sort_by { |k,v| k.to_s }.map do |k,v|
          "#{URI.escape k.to_s}=#{URI.escape v.to_s}"
        end

        url = @url.dup
        url.query = escaped_params.join '&'
        return url
      end
      
      # Override to convert the response to something besides a String, which
      # will get passed to +check_error+ and +parse_response+.
      def prepare_response(response)
        response
      end

      # Must parse results from +response+ into a Location.
      def parse_response(response)
        raise NotImplementedError
      end

    end
  end
end
