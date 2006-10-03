
module Geocode
  class Location
    attr_accessor :latitude, :longitude, :street, :city, :state, :zip, :country, :precision
    
    def initialize(attrs = {})
      attrs.each do |key,value|
        instance_variable_set "@#{key}", value
      end
    end
    
    # Returns an Array with latitude and longitude.
    def coordinates
      [latitude, longitude]
    end
  end
end