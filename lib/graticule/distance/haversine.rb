
module Graticule
  module Distance

    #
    # Thanks to Chris Veness for distance formulas.
    #   * http://www.movable-type.co.uk/scripts/LatLong.html
    #
    # Distance Measured usign the Haversine Formula
    # Works better at small distances than the Spherical Law of Cosines
    # R = earth’s radius (mean radius = 6,371km)
    # Δlat = lat2− lat1
    # Δlong = long2− long1
    # a = sin²(Δlat/2) + cos(lat1).cos(lat2).sin²(Δlong/2)
    # c = 2.atan2(√a, √(1−a))
    # d = R.c
    #
    class Haversine < DistanceFormula
  
      def self.distance(from, to, units = :miles)
        from_longitude  = deg2rad(from.longitude)
        from_latitude   = deg2rad(from.latitude)
        to_longitude    = deg2rad(to.longitude)
        to_latitude     = deg2rad(to.latitude)

        latitude_delta  = to_latitude - from_latitude
        longitude_delta = to_longitude - from_longitude

        a = Math.sin(latitude_delta/2)**2 + 
            Math.cos(from_latitude) * 
            Math.cos(to_latitude) * 
            Math.sin(longitude_delta/2)**2

        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

        d = EARTH_RADIUS[units.to_sym] * c
      end

      # # What formula is this?
      # def self.distance(from, to, units = :miles)
      #   from_longitude = deg2rad(from.longitude)
      #   from_latitude = deg2rad(from.latitude)
      #   to_longitude = deg2rad(to.longitude)
      #   to_latitude = deg2rad(to.latitude)
      # 
      #   Math.acos(
      #       Math.cos(from_longitude) *
      #       Math.cos(to_longitude) * 
      #       Math.cos(from_latitude) * 
      #       Math.cos(to_latitude) +
      # 
      #       Math.cos(from_latitude) *
      #       Math.sin(from_longitude) *
      #       Math.cos(to_latitude) *
      #       Math.sin(to_longitude) +
      # 
      #       Math.sin(from_latitude) *
      #       Math.sin(to_latitude)
      #   ) * EARTH_RADIUS[units.to_sym]
      # end
   
      
    end
  end
end