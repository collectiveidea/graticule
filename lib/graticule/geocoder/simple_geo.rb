require 'json'

module Graticule
  module Geocoder

    # First you need a SimpleGeo JSONP API key.  You can register for one here:
    # http://simplegeo.com/docs/clients-code-libraries/javascript-sdk
    #
    #     gg = Graticule.service(:SimpleGeo).new(SIMPLEGEO_TOKEN)
    #     location = gg.locate '1600 Amphitheater Pkwy, Mountain View, CA'
    #     location.coordinates
    #     #=> [37.423111, -122.081783]
    #
    class SimpleGeo < Base

      def initialize(token)
        @token  = token
        @url    = URI.parse 'http://api.simplegeo.com/1.0/context/address.json?'
      end

      def locate(query)
        get :address => "#{query}"
      end

    private

      def prepare_response(response)
        JSON.parse(response)
      end

      def parse_response(response)
        Location.new(
          :latitude    => response["query"]["latitude"],
          :longitude   => response["query"]["longitude"],
          :precision   => :unknown
        )
      end

      def check_error(response)
        raise Error, response["message"] unless response["message"].blank?
      end

      def make_url(params)
        super params.merge(:token => @token)
      end
    end
  end
end