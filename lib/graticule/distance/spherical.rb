module Graticule
  module Distance

    #
    # The Spherical Law of Cosines is the simplist though least accurate distance
    # formula (earth isn't a perfect sphere).
    #
    class Spherical < DistanceFormula

      # Calculate the distance between two Locations using the Spherical formula
      #
      #   Graticule::Distance::Spherical.distance(
      #     Graticule::Location.new(:latitude => 42.7654, :longitude => -86.1085),
      #     Graticule::Location.new(:latitude => 41.849838, :longitude => -87.648193)
      #   )
      #   #=> 101.061720831853
      #
      def self.distance(from, to, units = :miles)
        from_longitude  = from.longitude.to_radians
        from_latitude   = from.latitude.to_radians
        to_longitude    = to.longitude.to_radians
        to_latitude     = to.latitude.to_radians

        Math.acos(
            Math.sin(from_latitude) *
            Math.sin(to_latitude) +

            Math.cos(from_latitude) * 
            Math.cos(to_latitude) *
            Math.cos(to_longitude - from_longitude)
        ) * EARTH_RADIUS[units.to_sym]
      end

      def self.to_sql(options)
        options = {
          :units => :miles,
          :latitude_column => 'latitude',
          :longitude_column => 'longitude'
        }.merge(options)
        %{(ACOS(
            SIN(RADIANS(#{options[:latitude]})) *
            SIN(RADIANS(#{options[:latitude_column]})) +
            COS(RADIANS(#{options[:latitude]})) *
            COS(RADIANS(#{options[:latitude_column]})) *
            COS(RADIANS(#{options[:longitude_column]}) - RADIANS(#{options[:longitude]}))
          ) * #{Graticule::Distance::EARTH_RADIUS[options[:units].to_sym]})
        }.gsub("\n", '').squeeze(" ")
      end
  
    end
  end
end