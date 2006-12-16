module Graticule
  module Distance
    EARTH_RADIUS = { :kilometers => 6378.135, :miles => 3963.1676 }
    # WGS-84 numbers
    EARTH_MAJOR_AXIS_RADIUS = { :kilometers => 6378.137, :miles => 3963.19059 }
    EARTH_MINOR_AXIS_RADIUS = { :kilometers => 6356.7523142, :miles => 3949.90276 }

    class DistanceFormula
      
      def initialize
        raise NotImplementedError
      end
      
      def self.deg2rad(deg)
      	(deg * Math::PI / 180)
      end

      def self.rad2deg(rad)
      	(rad * 180 / Math::PI)
      end

    end
  end
end
