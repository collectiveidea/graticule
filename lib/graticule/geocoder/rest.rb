require 'rexml/document'

module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # Abstract class for implementing REST geocoders. Passes on a REXML::Document
    # to +check_errors+ and +parse_response+.
    class Rest < Base

    private
    
      def prepare_response(response)
        REXML::Document.new(response)
      end
      
    end
  end
end