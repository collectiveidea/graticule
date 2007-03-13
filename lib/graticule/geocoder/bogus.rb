module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # Bogus geocoder that can be used for test purposes
    class Bogus
    
      # returns a new location with the address set to the original query string
      def locate(address)
        Location.new :street => address
      end
    
    end

  end
end
