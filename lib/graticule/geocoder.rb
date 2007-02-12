
module Graticule
  
  # Get a geocoder for the given service
  #
  #   geocoder = Graticule.service(:google).new "api_key"
  #
  # See the documentation for your specific geocoder for more information
  #
  def self.service(name)
    self.const_get "#{name}_geocoder".camelize
  end

  # The Geocode class is the base class for all geocoder implementations. The
  # geocoders must implement:
  # 
  # * locate(address)  
  #
  class Geocoder
    def initialize
      raise NotImplementedError
    end
  end
  
  # Base error class
  class Error < RuntimeError; end
  class CredentialsError < Error; end

  # Raised when you try to locate an invalid address.
  class AddressError < Error; end

end