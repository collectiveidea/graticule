module Graticule
  module Distance

    #
    # The Vincenty Formula uses an ellipsoidal model of the earth, which is very accurate.
    #
    # Thanks to Chris Veness (http://www.movable-type.co.uk/scripts/LatLongVincenty.html)
    # for distance formulas.
    #
    class Vincenty < DistanceFormula

      # Calculate the distance between two Locations using the Vincenty formula
      #
      #   Graticule::Distance::Vincenty.distance(
      #     Graticule::Location.new(:latitude => 42.7654, :longitude => -86.1085),
      #     Graticule::Location.new(:latitude => 41.849838, :longitude => -87.648193)
      #   )
      #   #=> 101.070118000159
      #
      def self.distance(from, to, units = :miles)
        from_longitude  = from.longitude.to_radians
        from_latitude   = from.latitude.to_radians
        to_longitude    = to.longitude.to_radians
        to_latitude     = to.latitude.to_radians
        
        earth_major_axis_radius = EARTH_MAJOR_AXIS_RADIUS[units.to_sym]
        earth_minor_axis_radius = EARTH_MINOR_AXIS_RADIUS[units.to_sym]

        f = (earth_major_axis_radius - earth_minor_axis_radius) / earth_major_axis_radius

        l = to_longitude - from_longitude
        u1 = atan((1-f) * tan(from_latitude))
        u2 = atan((1-f) * tan(to_latitude))
        sin_u1 = sin(u1)
        cos_u1 = cos(u1)
        sin_u2 = sin(u2)
        cos_u2 = cos(u2)

        lambda = l
        lambda_p = 2 * PI
        iteration_limit = 20
        while (lambda-lambda_p).abs > 1e-12 && (iteration_limit -= 1) > 0
          sin_lambda = sin(lambda)
          cos_lambda = cos(lambda)
          sin_sigma = sqrt((cos_u2*sin_lambda) * (cos_u2*sin_lambda) + 
            (cos_u1*sin_u2-sin_u1*cos_u2*cos_lambda) * (cos_u1*sin_u2-sin_u1*cos_u2*cos_lambda))
          return 0 if sin_sigma == 0  # co-incident points
          cos_sigma = sin_u1*sin_u2 + cos_u1*cos_u2*cos_lambda
          sigma = atan2(sin_sigma, cos_sigma)
          sin_alpha = cos_u1 * cos_u2 * sin_lambda / sin_sigma
          cosSqAlpha = 1 - sin_alpha*sin_alpha
          cos2SigmaM = cos_sigma - 2*sin_u1*sin_u2/cosSqAlpha

          cos2SigmaM = 0 if cos2SigmaM.nan?  # equatorial line: cosSqAlpha=0 (§6)

          c = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha))
          lambda_p = lambda
          lambda = l + (1-c) * f * sin_alpha *
            (sigma + c*sin_sigma*(cos2SigmaM+c*cos_sigma*(-1+2*cos2SigmaM*cos2SigmaM)))
       end
       # formula failed to converge (happens on antipodal points)
       # We'll call Haversine formula instead.
       return Haversine.distance(from, to, units) if iteration_limit == 0 

       uSq = cosSqAlpha * (earth_major_axis_radius**2 - earth_minor_axis_radius**2) / (earth_minor_axis_radius**2)
       a = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)))
       b = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)))
       delta_sigma = b*sin_sigma*(cos2SigmaM+b/4*(cos_sigma*(-1+2*cos2SigmaM*cos2SigmaM)-
         b/6*cos2SigmaM*(-3+4*sin_sigma*sin_sigma)*(-3+4*cos2SigmaM*cos2SigmaM)))
         
        earth_minor_axis_radius * a * (sigma-delta_sigma)
      end
  
    end
  end
end