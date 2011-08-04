# encoding: UTF-8
module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # TODO: Reverse Geocoding
    class GeocoderCa < Base

      def initialize(auth = nil)
        @url = URI.parse 'http://geocoder.ca/'
        @auth = auth
      end

      def locate(address)
        get :locate => address.is_a?(String) ? address : location_from_params(address).to_s(:country => false)
      end

    private

      class Response
        include HappyMapper
        tag 'geodata'
        element :latitude, Float, :tag => 'latt'
        element :longitude, Float, :tag => 'longt'
        element :street_number, String, :deep => true, :tag => 'stnumber'
        element :street_name, String, :deep => true, :tag => 'staddress'
        element :locality, String, :deep => true, :tag => 'city'
        element :postal_code, String, :tag => 'postal'
        element :region, String, :deep => true, :tag => 'prov'

        class Error
          include HappyMapper
          tag 'error'
          element :code, Integer
          element :description, String
        end

        has_one :error, Error

        def street
          [street_number, street_name].join(' ')
        end
      end

      def prepare_response(xml)
        Response.parse(xml, :single => true)
      end

      def parse_response(response) #:nodoc:
        Location.new(
          :latitude  => response.latitude,
          :longitude => response.longitude,
          :street    => response.street,
          :locality  => response.locality,
          :region    => response.region
        )
      end

      def check_error(response) #:nodoc:
        if response.error
          exception = case response.error.code
          when 1..3; CredentialsError
          when 4..8; AddressError
          else;      Error
          end
          raise exception, response.error.message
        end
      end

      def make_url(params) #:nodoc:
        params[:auth]       = @auth if @auth
        params[:standard]   = 1
        params[:showpostal] = 1
        params[:geoit]      = 'XML'
        super params
      end


    end
  end
end