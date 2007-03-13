
module Graticule
  
  # Get a geocoder for the given service
  #
  #   geocoder = Graticule.service(:google).new "api_key"
  #
  # See the documentation for your specific geocoder for more information
  #
  def self.service(name)
    Geocoder.const_get name.to_s.camelize
  end
  
  # Base error class
  class Error < RuntimeError; end
  class CredentialsError < Error; end

  # Raised when you try to locate an invalid address.
  class AddressError < Error; end

end