module Graticule
  module Geocoder
    class Mapbox < Base
      BASE_URL = "http://api.tiles.mapbox.com"

      def initialize(api_key)
        @api_key = api_key
      end

      def locate(address)
        get :q => address
      end

      protected

      # A result looks like:
      # [
      #   {
      #     "id"=>"address.110173544177",
      #     "lon"=>-122.02912,
      #     "lat"=>37.33054,
      #     "name"=>"1 Infinite Loop",
      #     "type"=>"address"
      #   }, {
      #     "id"=>"mapbox-places.95014",
      #     "name"=>"Cupertino",
      #     "type"=>"city"
      #   }, {
      #     "id"=>"province.1112151813",
      #     "name"=>"California",
      #     "type"=>"province"
      #   }, {
      #     "id"=>"country.4150104525",
      #     "name"=>"United States",
      #     "type"=>"country"
      #   }
      # ]
      class Result
        attr_accessor :lat, :lon, :address, :city, :province, :country, :precision, :postal_code

        def initialize(input)
          self.precision = ::Graticule::Precision::Unknown

          input.each do |tuple|
            case tuple["type"]
            when "address"
              self.lat = tuple["lat"]
              self.lon = tuple["lon"]
              self.address = tuple["name"]

              set_higher_precision(::Graticule::Precision::Address)
            when "city"
              self.city = tuple["name"]
              set_higher_precision(::Graticule::Precision::Locality)
              self.postal_code = tuple["id"].split(".")[1]
            when "province"
              self.province = tuple["name"]
              set_higher_precision(::Graticule::Precision::Region)
            when "country"
              self.country = tuple["name"]
              set_higher_precision(::Graticule::Precision::Country)
            end
          end
        end

        private

        def set_higher_precision(p)
          if self.precision < p
            self.precision = p
          end
        end
      end

      def make_url(params)
        query = URI.escape(params[:q].to_s)
        url   = "#{BASE_URL}/v3/#{@api_key}/geocode/#{query}.json"

        URI.parse(url)
      end

      def check_error(response)
      end

      def prepare_response(response)
        JSON.parse(response)
      end

      def parse_response(response)
        # Pull data from the first result since we get a bunch
        result = Result.new(response["results"][0])

        Location.new(
          :latitude    => result.lat,
          :longitude   => result.lon,
          :street      => result.address,
          :locality    => result.city,
          :region      => result.province,
          :postal_code => result.postal_code,
          :country     => result.country,
          :precision   => result.precision
        )
      end
    end
  end
end