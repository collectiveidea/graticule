module Graticule
  module Distance
    #
    # The Haversine Formula works better at small distances than the Spherical Law of Cosines
    #
    # Thanks to Chris Veness (http://www.movable-type.co.uk/scripts/LatLong.html)
    # for distance formulas.
    #
    class Haversine < DistanceFormula
      
      # Calculate the distance between two Locations using the Haversine formula
      #
      #   Graticule::Distance::Haversine.distance(
      #     Graticule::Location.new(:latitude => 42.7654, :longitude => -86.1085),
      #     Graticule::Location.new(:latitude => 41.849838, :longitude => -87.648193)
      #   )
      #   #=> 101.061720831836
      #
      def self.distance(from, to, units = :miles)
        from_longitude  = from.longitude.to_radians
        from_latitude   = from.latitude.to_radians
        to_longitude    = to.longitude.to_radians
        to_latitude     = to.latitude.to_radians

        latitude_delta  = to_latitude - from_latitude
        longitude_delta = to_longitude - from_longitude

        a = sin(latitude_delta/2)**2 + 
            cos(from_latitude) * 
            cos(to_latitude) * 
            sin(longitude_delta/2)**2

        c = 2 * atan2(sqrt(a), sqrt(1-a))

        d = EARTH_RADIUS[units.to_sym] * c
      end

    end
  end
end