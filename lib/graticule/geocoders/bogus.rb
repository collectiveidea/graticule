module Graticule #:nodoc:

  # Bogus geocoder that can be used for test purposes
  class BogusGeocoder < Geocoder
    
    def locate(address)
      Location.new :street => address
    end
    
  end
end
