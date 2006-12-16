
module Graticule
  module Distance
    class Haversine < DistanceFormula
  
      def self.distance(from, to, units = :miles)
        first_longitude = deg2rad(from.longitude)
        first_latitude = deg2rad(from.latitude)
        second_longitude = deg2rad(to.longitude)
        second_latitude = deg2rad(to.latitude)

        Math.acos(
            Math.cos(first_longitude) *
            Math.cos(second_longitude) * 
            Math.cos(first_latitude) * 
            Math.cos(second_latitude) +

            Math.cos(first_latitude) *
            Math.sin(first_longitude) *
            Math.cos(second_latitude) *
            Math.sin(second_longitude) +

            Math.sin(first_latitude) *
            Math.sin(second_latitude)
        ) * EARTH_RADIUS[units.to_sym]
      end
      
    end
  end
end