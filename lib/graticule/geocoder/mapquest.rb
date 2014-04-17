# encoding: UTF-8
module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # Mapquest uses the Licenced Community API which requires an api key. You can sign up an account
    # and get an api key by registering at: http://developer.mapquest.com/
    #
    # mq = Graticule.service(:mapquest).new(API_KEY)
    # location = gg.locate('44 Allen Rd., Lovell, ME 04051')
    # [42.78942, -86.104424]
    #
    class Mapquest < Base

      def initialize(api_key, open = false, limited_to_country = nil)
        @api_key = api_key
        @url = if open
                 URI.parse('http://open.mapquestapi.com/geocoding/v1/address')
               else
                 URI.parse('http://www.mapquestapi.com/geocoding/v1/address')
               end
        @country_filter = limited_to_country
      end

      # Locates +address+ returning a Location
      def locate(address)
        get :q => address.is_a?(String) ? address : location_from_params(address).to_s
      end

      protected

      def make_url(params) #:nodoc
        request = Mapquest::Request.new(params[:q], @api_key)
        url = @url.dup
        url.query = request.query
        url
      end

      class Request
        def initialize(address, api_key)
          @address = address
          @api_key = api_key
        end

        def query
          "key=#{URI.escape(@api_key)}&outFormat=xml&inFormat=kvp&location=#{URI.escape(@address)}"
        end
      end

      # See http://www.mapquestapi.com/geocoding/geocodequality.html#granularity
      PRECISION = {
        'P1' => Precision::Point,
        'L1' => Precision::Address,
        'I1' => Precision::Street,
        'B1' => Precision::Street,
        'B2' => Precision::Street,
        'B3' => Precision::Street,
        'Z3' => Precision::PostalCode,
        'Z4' => Precision::PostalCode,
        'Z2' => Precision::PostalCode,
        'Z1' => Precision::PostalCode,
        'A5' => Precision::Locality,
        'A4' => Precision::Region,
        'A3' => Precision::Region,
        'A1' => Precision::Country
      }

      class Address
        include HappyMapper
        tag 'location'
        element :latitude, Float, :tag => 'lat', :deep => true
        element :longitude, Float, :tag => 'lng', :deep => true
        element :street, String, :tag => 'street'
        element :locality, String, :tag => 'adminArea5'
        element :region, String, :tag => 'adminArea3'
        element :postal_code, String, :tag => 'postalCode'
        element :country, String, :tag => 'adminArea1'
        element :result_code, String, :tag => 'geocodeQualityCode'

        def precision
          PRECISION[result_code.to_s[0,2]] || :unknown
        end
      end

      class Locations
        include HappyMapper
        has_many :addresses, Address, :tag => "location"
      end

      class Result
        include HappyMapper
        has_one :locations, Locations, :tag => "locations"
      end

      class Response
        include HappyMapper
        has_one :result, Result, :deep => true
      end

      def prepare_response(xml)
        Response.parse(xml, :single => true)
      end

      # Extracts a location from +xml+.
      def parse_response(response) #:nodoc:
        if @country_filter
          addr = response.result.locations.addresses.select{|address| address.country == @country_filter}.first
        else
          addr = response.result.locations.addresses.first
        end
        Location.new(
          :latitude    => addr.latitude,
          :longitude   => addr.longitude,
          :street      => addr.street,
          :locality    => addr.locality,
          :region      => addr.region,
          :postal_code => addr.postal_code,
          :country     => addr.country,
          :precision   => addr.precision
        )
      end

      # Extracts and raises any errors in +xml+
      def check_error(xml) #:nodoc
      end

    end
  end
end
