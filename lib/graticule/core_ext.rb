module Graticule
  module RadiansAndDegrees
    # Convert from degrees to radians
    def to_radians
      ( self / 360.0 ) * Math::PI * 2
    end
  
    # Convert from radians to degrees
    def to_degrees
      ( self * 360.0 ) / Math::PI / 2
    end
  end
end

Numeric.send :include, Graticule::RadiansAndDegrees