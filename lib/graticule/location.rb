module Graticule
  
  # A geographic location
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
    
    # Calculate the distance to another location.  See the various Distance formulas
    # for more information
    def distance_to(destination, units = :miles, formula = :haversine)
      "Graticule::Distance::#{formula.to_s.titleize}".constantize.distance(self, destination)
    end
    
    # Where would I be if I dug through the center of the earth?
    def antipode
      new_longitude = longitude + (longitude >= 0 ? -180 : 180)
      Location.new(:latitude => -latitude, :longitude => new_longitude)
    end
    alias_method :antipodal_location, :antipode
    
    def to_s(coordinates = false)
      result = ""
      result << "#{street}\n" if street
      result << [city, [state, zip, country].compact.join(" ")].compact.join(", ")
      result << "\nlatitude: #{latitude}, longitude: #{longitude}" if coordinates && [latitude, longitude].any?
      result
    end
    
  end
end