require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

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
          assert_in_delta formula.distance(washington_dc, chicago), formula.distance(chicago, washington_dc), 0.00001
          assert_in_delta 594.820, formula.distance(washington_dc, chicago), 1.0
          assert_in_delta 594.820, formula.distance(washington_dc, chicago, :miles), 1.0
          assert_in_delta 957.275, formula.distance(washington_dc, chicago, :kilometers), 1.0
        end
      end
      
      def test_distance_between_antipodal_points
        # The Vincenty formula will be indeterminant with antipodal points.
        # See http://mathworld.wolfram.com/AntipodalPoints.html
        washington_dc = Location.new(:latitude => 38.898748, :longitude => -77.037684)
        chicago = Location.new(:latitude => 41.85, :longitude => -87.65)
        
        # First, test the deltas.
        FORMULAS.each do |formula|
          assert_in_delta 12450.6582171051, 
            formula.distance(chicago, chicago.antipodal_location), 1.0
          assert_in_delta 12450.6582171051, 
            formula.distance(washington_dc, washington_dc.antipodal_location), 1.0
          assert_in_delta 12450.6582171051, 
            formula.distance(chicago, chicago.antipodal_location, :miles), 1.0
          assert_in_delta 12450.6582171051, 
            formula.distance(washington_dc, washington_dc.antipodal_location, :miles), 1.0
          assert_in_delta 20037.50205960391, 
            formula.distance(chicago, chicago.antipodal_location, :kilometers), 1.0
          assert_in_delta 20037.5020596039, 
            formula.distance(washington_dc, washington_dc.antipodal_location, :kilometers), 1.0
        end
        
        # Next, test Vincenty.  Vincenty will use haversine instead of returning NaN on antipodal points
        assert_equal Haversine.distance(washington_dc, washington_dc.antipodal_location), 
          Vincenty.distance(washington_dc, washington_dc.antipodal_location)
        assert_equal Haversine.distance(chicago, chicago.antipodal_location),
          Vincenty.distance(chicago, chicago.antipodal_location)
      end
    end
  end
end