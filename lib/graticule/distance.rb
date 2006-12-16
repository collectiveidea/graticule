module Graticule
  module Distance
    class DistanceFormula
      EARTH_RADIUS = { :kilometers => 6378.135, :miles => 3963.1676 }
      
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
