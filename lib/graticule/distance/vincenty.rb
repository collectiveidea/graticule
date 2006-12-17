module Graticule
  module Distance

    #
    # Thanks to Chris Veness for distance formulas.
    #   * http://www.movable-type.co.uk/scripts/LatLongVincenty.html
    #
    # Distance Measured using the Vincenty Formula
    # Very accurate, using an accurate ellipsoidal model of the earth
    # a, b = major & minor semiaxes of the ellipsoid	 
    # f = flattening (a−b)/a	 
    # φ1, φ2 = geodetic latitude	 
    # L = difference in longitude	 
    # U1 = atan((1−f).tanφ1) (U is ‘reduced latitude’)	 
    # U2 = atan((1−f).tanφ2)	 
    # λ = L, λ′ = 2π	 
    # while abs(λ−λ′) > 10-12 { (i.e. 0.06mm)	 
    #     	sinσ = √[ (cos_u2.sinλ)² + (cos_u1.sin_u2 − sin_u1.cos_u2.cosλ)² ]	(14)
    #  	cosσ = sin_u1.sin_u2 + cos_u1.cos_u2.cosλ	(15)
    #  	σ = atan2(sinσ, cosσ)	(16)
    #  	sinα = cos_u1.cos_u2.sinλ / sinσ	(17)
    #  	cos²α = 1 − sin²α (trig identity; §6)	 
    #  	cos2σm = cosσ − 2.sin_u1.sin_u2/cos²α	(18)
    #  	C = f/16.cos²α.[4+f.(4−3.cos²α)]	(10)
    #  	λ′ = λ	 
    #  	λ = L + (1−C).f.sinα.{σ+C.sinσ.[cos2σm+C.cosσ.(−1+2.cos²2σm)]}	(11)
    # }	 	 
    # u² = cos²α.(a²−b²)/b²	 
    # A = 1+u²/16384.{4096+u².[−768+u².(320−175.u²)]}	(3)
    # B = u²/1024.{256+u².[−128+u².(74−47.u²)]}	(4)
    # Δσ = B.sinσ.{cos2σm+B/4.[cosσ.(−1+2.cos²2σm) − B/6.cos2σm.(−3+4.sin²σ).(−3+4.cos²2σm)]}	(6)
    # s = b.A.(σ−Δσ)	(19)
    # α1 = atan2(cos_u2.sinλ, cos_u1.sin_u2 − sin_u1.cos_u2.cosλ)	(20)
    # α2 = atan2(cos_u1.sinλ, −sin_u1.cos_u2 + cos_u1.sin_u2.cosλ)	(21)
    # Where:
    # 
    # s is the distance (in the same units as a & b)
    # α1 is the initial bearing, or forward azimuth
    # α2 is the final bearing (in direction p1→p2)
    #
    class Vincenty < DistanceFormula

      def self.distance(from, to, units = :miles)
        from_longitude   = deg2rad(from.longitude)
        from_latitude    = deg2rad(from.latitude)
        to_longitude  = deg2rad(to.longitude)
        to_latitude   = deg2rad(to.latitude)
        
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