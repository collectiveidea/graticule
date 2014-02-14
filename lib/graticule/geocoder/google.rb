# encoding: UTF-8
require 'json'
module Graticule #:nodoc:
  module Geocoder #:nodoc:
    #   gg = Graticule.service(:google).new
    #   location = gg.locate '1600 Amphitheater Pkwy, Mountain View, CA'
    #   p location.coordinates
    #   #=> [37.423111, -122.081783
    #
    # If you have a Google business account, initialize with:
    #
    #   gg = Graticule.service(:google).new(MAPS_API_KEY, MAPS_CLIENT_ID)
    #
    class Google < Base
      # https://developers.google.com/maps/documentation/geocoding/

      def initialize(key=nil, client_id=nil)
        @key = key
        @client_id = client_id
        @url = URI.parse 'http://maps.googleapis.com/maps/api/geocode/json'
      end

      # Locates +address+ returning a Location
      def locate(address)
        get :address => address.is_a?(String) ? address : location_from_params(address).to_s
      end

    private
      class Result
        attr_accessor :latitude, :longitude, :street_number, :route, :locality, :region, :postal_code, :country, :precision, :formatted_address
        def initialize(attribs)
          @latitude = attribs["geometry"]["location"]["lat"]
          @longitude = attribs["geometry"]["location"]["lng"]
          @formatted_address = attribs["formatted_address"]
          @precision = determine_precision(attribs["types"])
          parse_address_components(attribs["address_components"])
        end

        def parse_address_components(components)
          components.each do |component|
            component["types"].each do |type|
              case type
              when "street_number"
                @street_number = component["short_name"]
              when "route"
                @route = component["short_name"]
              when "locality", "sublocality"
                @locality = component["long_name"] 
              when "administrative_area_level_1"
                @region = component["short_name"]
              when "country"
                @country = component["short_name"]
              when "postal_code"
                @postal_code = component["long_name"]
              end
            end
          end
        end

        def street
          "#{@street_number.to_s}#{" " unless @street_number.blank? || @route.blank?}#{@route.to_s}"
        end

        def determine_precision(types)
          precision = Precision::Unknown
          types.each do |type|
            precision = case type
            when "premise", "subpremise"
              Precision::Premise
            when "street_address"
              Precision::Address
            when "route", "intersection"
              Precision::Street
            when "postal_code"
              Precision::PostalCode
            when "locality","sublocality","neighborhood"
              Precision::Locality
            when "administrative_area_level_1", "administrative_area_level_2","administrative_area_level_3"
              Precision::Region
            when "country"
              Precision::Country
            else
              precision
            end
          end
          return precision
        end
      end

      class Response
        attr_reader :results, :status
        def initialize(json)
          result = JSON.parse(json)
          @results = result["results"].collect{|attribs| Result.new(attribs)}
          @status = result["status"]
        end
      end

      def prepare_response(json)
        Response.new(json)
      end

      def parse_response(response) #:nodoc:
        result = response.results.first
        Location.new(
          :latitude    => result.latitude,
          :longitude   => result.longitude,
          :street      => result.street,
          :locality    => result.locality,
          :region      => result.region,
          :postal_code => result.postal_code,
          :country     => result.country,
          :precision   => result.precision
        )
      end

      # Extracts and raises an error from +json+, if any.
      def check_error(response) #:nodoc:
        case response.status
        when "OK" then # ignore, ok
        when "ZERO_RESULTS" then
          raise AddressError, 'unknown address'
        when "OVER_QUERY_LIMIT"
          raise CredentialsError, 'over query limit'
        when "REQUEST_DENIED"
          raise CredentialsError, 'request denied'
        when "INVALID_REQUEST"
          raise AddressError, 'missing address'
        when "UNKNOWN_ERROR"
          raise Error, "unknown server error. Try again."
        else
          raise Error, "unkown error #{response.status}"
        end
      end

      # Creates a URL from the Hash +params+..
      #
      # If initialized with a key and client id for a Business account, signs
      # the url as required by v3 of the library:
      #
      # https://developers.google.com/maps/documentation/business/webservices#digital_signatures
      # 
      def make_url(params) #:nodoc:
        if @key && @client_id
          url = super params.merge(:sensor => false, :client => @client_id)
          make_signed_url(url)
        else
          super params.merge(:sensor => false)
        end
      end

      def make_signed_url(original_url) #:nodoc:
        require "base64"
        require 'openssl'
        url_to_sign = "#{original_url.path}?#{original_url.query}"
        decoded_key = Base64.decode64(@key.tr("-_", "+/"))
        signature = OpenSSL::HMAC.digest('sha1', decoded_key, url_to_sign)
        encoded_signature = Base64.encode64(signature).tr("+/", "-_")
        signed_url = original_url.to_s + "&signature=#{encoded_signature}"
        #puts signed_url
        URI.parse signed_url
      end

    end
  end
end
