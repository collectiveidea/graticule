
module Graticule
  class Location
    attr_accessor :latitude, :longitude, :street, :city, :state, :zip, :country, :precision, :warning
    
    def initialize(attrs = {})
      attrs.each do |key,value|
        instance_variable_set "@#{key}", value
      end
    end
    
    # Returns an Array with latitude and longitude.
    def coordinates
      [latitude, longitude]
    end
    
    def ==(object)
      super(object) || [:latitude, :longitude, :street, :city, :state, :zip, :country, :precision].all? do |m|
        object.respond_to?(m) && self.send(m) == object.send(m)
      end
    end
  end
end