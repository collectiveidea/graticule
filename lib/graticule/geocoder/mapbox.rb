module Graticule #:nodoc:
  module Geocoder #:nodoc:
    class Mapbox < Base
      BASE_URL = "http://api.mapbox.com/geocoding/v5/mapbox.places"

      def initialize(api_key)
        @api_key = api_key
      end

      def locate(address)
        get :q => address
      end

      protected

      class Result
        attr_accessor :lat, :lon, :precision

        def initialize(attributes)
          self.precision = ::Graticule::Precision::Unknown
          self.lon = attributes["center"][0]
          self.lat = attributes["center"][1]
        end
      end

      def make_url(params)
        query = URI.escape(params[:q].to_s)
        url = "#{BASE_URL}/#{query}.json?access_token=#{@api_key}"

        URI.parse(url)
      end

      def check_error(response)
        raise AddressError, 'unknown address' if (response["features"].nil? || response["features"].empty?)
      end

      def prepare_response(response)
        JSON.parse(response)
      end

      def parse_response(response)
        # Pull data from the first result since we get a bunch
        result = Result.new(response["features"][0])

        Location.new(
          :latitude  => result.lat,
          :longitude => result.lon,
        )
      end
    end
  end
end
