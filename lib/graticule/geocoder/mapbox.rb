require 'json'
module Graticule #:nodoc:
  module Geocoder #:nodoc:
    class Mapbox < Base

      def initialize(api_key)
        @api_key = api_key
        @url = "http://api.mapbox.com"
      end

      def locate(address)
        get :q => address
      end

      protected

      class Result
        attr_accessor :lat, :lon, :address, :city, :province, :country, :precision, :postal_code

        def initialize(input)
          self.precision = ::Graticule::Precision::Unknown
          self.lon = input["center"][0]
          self.lat = input["center"][1]
        end

        private
      end

      def make_url(params)
        query = URI.escape(params[:q].to_s)
        @url = "http://api.mapbox.com/geocoding/v5/mapbox.places/#{query}.json?access_token=#{@api_key}"

        URI.parse(@url)
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
          :latitude    => result.lat,
          :longitude   => result.lon,
        )
      end
    end
  end
end
