module Graticule
  module Distance

    #
    # Thanks to Chris Veness for distance formulas.
    #   * http://www.movable-type.co.uk/scripts/LatLongVincenty.html
    #
    # Distance Measured usign the Spherical Law of Cosines
    # Simplist though least accurate (earth isn't a perfect sphere)
    # d = acos(sin(lat1).sin(lat2)+cos(lat1).cos(lat2).cos(long2−long1)).R
    #
    class Spherical < DistanceFormula

      def self.distance(from, to, units = :miles)
        from_longitude   = deg2rad(from.longitude)
        from_latitude    = deg2rad(from.latitude)
        to_longitude  = deg2rad(to.longitude)
        to_latitude   = deg2rad(to.latitude)

        acos(
            sin(from_latitude) *
            sin(to_latitude) +
            
            cos(from_latitude) * 
            cos(to_latitude) *
            cos(to_longitude - from_longitude)
        ) * EARTH_RADIUS[units.to_sym]
      end

  
    end
  end
end