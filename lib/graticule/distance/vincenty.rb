module Graticule
  module Distance

    #
    # Thanks to Chris Veness for distance formulas.
    #   * http://www.movable-type.co.uk/scripts/LatLongVincenty.html
    #
    # Distance Measured usign the Vincenty Formula
    # Very accurate, using an accurate ellipsoidal model of the earth
    # a, b = major & minor semiaxes of the ellipsoid	 
    # f = flattening (a−b)/a	 
    # φ1, φ2 = geodetic latitude	 
    # L = difference in longitude	 
    # U1 = atan((1−f).tanφ1) (U is ‘reduced latitude’)	 
    # U2 = atan((1−f).tanφ2)	 
    # λ = L, λ′ = 2π	 
    # while abs(λ−λ′) > 10-12 { (i.e. 0.06mm)	 
    #     	sinσ = √[ (cosU2.sinλ)² + (cosU1.sinU2 − sinU1.cosU2.cosλ)² ]	(14)
    #  	cosσ = sinU1.sinU2 + cosU1.cosU2.cosλ	(15)
    #  	σ = atan2(sinσ, cosσ)	(16)
    #  	sinα = cosU1.cosU2.sinλ / sinσ	(17)
    #  	cos²α = 1 − sin²α (trig identity; §6)	 
    #  	cos2σm = cosσ − 2.sinU1.sinU2/cos²α	(18)
    #  	C = f/16.cos²α.[4+f.(4−3.cos²α)]	(10)
    #  	λ′ = λ	 
    #  	λ = L + (1−C).f.sinα.{σ+C.sinσ.[cos2σm+C.cosσ.(−1+2.cos²2σm)]}	(11)
    # }	 	 
    # u² = cos²α.(a²−b²)/b²	 
    # A = 1+u²/16384.{4096+u².[−768+u².(320−175.u²)]}	(3)
    # B = u²/1024.{256+u².[−128+u².(74−47.u²)]}	(4)
    # Δσ = B.sinσ.{cos2σm+B/4.[cosσ.(−1+2.cos²2σm) − B/6.cos2σm.(−3+4.sin²σ).(−3+4.cos²2σm)]}	(6)
    # s = b.A.(σ−Δσ)	(19)
    # α1 = atan2(cosU2.sinλ, cosU1.sinU2 − sinU1.cosU2.cosλ)	(20)
    # α2 = atan2(cosU1.sinλ, −sinU1.cosU2 + cosU1.sinU2.cosλ)	(21)
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
       u1 = Math.atan((1-f) * Math.tan(from_latitude))
       u2 = Math.atan((1-f) * Math.tan(to_latitude))
       sinU1 = Math.sin(u1)
       cosU1 = Math.cos(u1)
       sinU2 = Math.sin(u2)
       cosU2 = Math.cos(u2)

       lambda = l
       lambdaP = 2*Math::PI
         iterLimit = 20;
         while (lambda-lambdaP).abs > 1e-12 && --iterLimit>0
           sinLambda = Math.sin(lambda)
           cosLambda = Math.cos(lambda)
           sinSigma = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + 
             (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda))
           return 0 if sinSigma==0  # co-incident points
           cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda
           sigma = Math.atan2(sinSigma, cosSigma)
           sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma
           cosSqAlpha = 1 - sinAlpha*sinAlpha
           cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha

           cos2SigmaM = 0 if cos2SigmaM.nan?  # equatorial line: cosSqAlpha=0 (§6)

           c = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha))
           lambdaP = lambda
           lambda = l + (1-c) * f * sinAlpha *
             (sigma + c*sinSigma*(cos2SigmaM+c*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)))
         end
         return NaN if (iterLimit==0)  # formula failed to converge

         uSq = cosSqAlpha * (earth_major_axis_radius**2 - earth_minor_axis_radius**2) / (earth_minor_axis_radius**2);
         bigA = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
         bigB = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
         deltaSigma = bigB*sinSigma*(cos2SigmaM+bigB/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-
           bigB/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
         s = earth_minor_axis_radius*bigA*(sigma-deltaSigma);

         #s = s.toFixed(3) # round to 1mm precision
         return s
      end
  
    end
  end
end