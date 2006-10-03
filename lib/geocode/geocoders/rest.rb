require 'open-uri'
require 'rexml/document'

module Geocode #:nodoc:

  ##
  # Abstract class for implementing REST APIs.
  #
  # === Example
  #
  # The following methods must be implemented in sublcasses:
  #
  # +initialize+:: Sets @url to the service enpoint.
  # +check_error+:: Checks for errors in the server response.
  # +parse_response+:: Extracts information from the server response.
  #
  # If you have extra URL paramaters (application id, output type) or need to
  # perform URL customization, override +make_url+.
  #
  #   class FakeService < RCRest
  #   
  #     class Error < RCRest::Error; end
  #   
  #     def initialize(appid)
  #       @appid = appid
  #       @url = URI.parse 'http://example.com/test'
  #     end
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
  #     def parse_response(xml)
  #       return xml
  #     end
  #   
  #     def test(query)
  #       get :q => query
  #     end
  #   
  #   end

  class RestGeocoder < Geocoder

    ##
    # Error class.

    class Error < RuntimeError; end

    ##
    # Web services initializer.
    #
    # Concrete web services implementations must set the +url+ instance
    # variable which must be a URI.

    def initialize
      raise NotImplementedError
    end

    ##
    # Must extract and raise an error from +xml+, an REXML::Document, if any.
    # Must returns if no error could be found.

    def check_error(xml)
      raise NotImplementedError
    end

    ##
    # Performs a GET request with +params+.  Calls the parse_response method on
    # the concrete class with an REXML::Document instance and returns its
    # result.

    def get(params = {})
      url = make_url params

      url.open do |xml|
        res = REXML::Document.new xml.read

        check_error res

        return parse_response(res)
      end
    rescue OpenURI::HTTPError => e
      xml = REXML::Document.new e.io.read
      check_error xml
      raise
    end

    ##
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

    ##
    # Must parse results from +xml+, an REXML::Document, into something sensible
    # for the API.

    def parse_response(xml)
      raise NotImplementedError
    end

  end

  
end