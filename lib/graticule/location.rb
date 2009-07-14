module Graticule
  
  # A geographic location
  class Location
    attr_accessor :latitude, :longitude, :street, :locality, :region, :postal_code, :country, :precision, :warning
    alias_method :city, :locality
    alias_method :state, :region
    alias_method :zip, :postal_code
    
    def initialize(attrs = {})
      attrs.each do |key,value|
        instance_variable_set "@#{key}", value
      end
      self.precision ||= :unknown
    end
    
    def attributes
      [:latitude, :longitude, :street, :locality, :region, :postal_code, :country, :precision].inject({}) do |result,attr|
        result[attr] = self.send(attr) unless self.send(attr).blank?
        result
      end
    end
    
    def blank?
      attributes.except(:precision).empty?
    end
    
    # Returns an Array with latitude and longitude.
    def coordinates
      [latitude, longitude]
    end
    
    def ==(other)
      other.respond_to?(:attributes) ? attributes == other.attributes : false
    end
    
    # Calculate the distance to another location.  See the various Distance formulas
    # for more information
    def distance_to(destination, options = {})
      options = {:formula => :haversine, :units => :miles}.merge(options)
      "Graticule::Distance::#{options[:formula].to_s.titleize}".constantize.distance(self, destination, options[:units])
    end
    
    # Where would I be if I dug through the center of the earth?
    def antipode
      Location.new :latitude => -latitude, :longitude => longitude + (longitude >= 0 ? -180 : 180)
    end
    alias_method :antipodal_location, :antipode
    
    def to_s(options = {})
      options = {:coordinates => false, :country => true}.merge(options)
      result = ""
      result << "#{street}\n" if street
      result << [locality, [region, postal_code].compact.join(" ")].compact.join(", ")
      result << " #{country}" if options[:country] && country
      result << "\nlatitude: #{latitude}, longitude: #{longitude}" if options[:coordinates] && [latitude, longitude].any?
      result
    end
    
  end
end
