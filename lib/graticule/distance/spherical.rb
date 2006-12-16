module Graticule
  module Distance

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

        Math.acos(
            Math.sin(from_latitude) *
            Math.sin(to_latitude) +

            Math.cos(from_latitude) * 
            Math.cos(to_latitude) *
            Math.cos(to_longitude - from_longitude)
        ) * EARTH_RADIUS[units.to_sym]
      end

  
    end
  end
end