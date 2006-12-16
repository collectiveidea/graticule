require File.dirname(__FILE__) + '/../../test_helper'

module Graticule
  module Distance
    class DistanceFormulaTest < Test::Unit::TestCase
      EARTH_RADIUS_IN_MILES = 3963.1676
      EARTH_RADIUS_IN_KILOMETERS = 6378.135

      FORMULAS = [Haversine, Spherical, Vincenty]

      def test_earth_radius
        assert_equal EARTH_RADIUS_IN_MILES, EARTH_RADIUS[:miles]
        assert_equal EARTH_RADIUS_IN_KILOMETERS, EARTH_RADIUS[:kilometers]
      end

      def test_distance
        washington_dc = Location.new(:latitude => 38.898748, :longitude => -77.037684)
        chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
        
        FORMULAS.each do |formula|
          assert_in_delta formula.distance(washington_dc, chicago), formula.distance(chicago, washington_dc), 0.1
          assert_in_delta 594.820, formula.distance(washington_dc, chicago), 1.0
          assert_in_delta 594.820, formula.distance(washington_dc, chicago, :miles), 1.0
          assert_in_delta 957.275, formula.distance(washington_dc, chicago, :kilometers), 1.0
        end
      end
      
    end
  end
end