module Graticule #:nodoc:
  module Geocoder #:nodoc:
  
    # Yahoo geocoding API.
    #
    # http://developer.yahoo.com/maps/rest/V1/geocode.html
    class Yahoo < Base

      PRECISION = {
        "country" => Precision::Country,
        "state"   => Precision::Region,
        "city"    => Precision::Locality,
        "zip+4"   => Precision::PostalCode,
        "zip+2"   => Precision::PostalCode,
        "zip"     => Precision::PostalCode,
        "street"  => Precision::Street,
        "address" => Precision::Address
      }

      # Web services initializer.
      #
      # The +appid+ is the Application ID that uniquely identifies your
      # application.  See: http://developer.yahoo.com/faq/index.html#appid
      #
      # See http://developer.yahoo.com/search/rest.html
      def initialize(appid)
        @appid = appid
        @url = URI.parse "http://api.local.yahoo.com/MapsService/V1/geocode"
      end

      # Returns a Location for +address+.
      #
      # The +address+ can be any of:
      # * city, state
      # * city, state, zip
      # * zip
      # * street, city, state
      # * street, city, state, zip
      # * street, zip
      def locate(address)
        location = (address.is_a?(String) ? address : location_from_params(address).to_s(:country => false))
        # yahoo pukes on line breaks
        get :location => location.gsub("\n", ', ')
      end
    
    private
    
      class Address
        include HappyMapper
        tag 'Result'
        
        attribute :precision, String
        attribute :warning, String
        element :latitude, Float, :tag => 'Latitude'
        element :longitude, Float, :tag => 'Longitude'
        element :street, String, :tag => 'Address'
        element :locality, String, :tag => 'City'
        element :region, String, :tag => 'State'
        element :postal_code, String, :tag => 'Zip'
        element :country, String, :tag => 'Country'
        
        def precision
          PRECISION[@precision] || :unknown
        end
      end
      
      class Result
        include HappyMapper
        tag 'ResultSet'
        has_many :addresses, Address
      end
      
      class Error
        include HappyMapper
        tag 'Error'
        element :message, String, :tag => 'Message'
      end
      
      def parse_response(response) # :nodoc:
        addr = Result.parse(response, :single => true).addresses.first
        Location.new(
          :latitude    => addr.latitude,
          :longitude   => addr.longitude,
          :street      => addr.street,
          :locality    => addr.locality,
          :region      => addr.region,
          :postal_code => addr.postal_code,
          :country     => addr.country,
          :precision   => addr.precision,
          :warning     => addr.warning
        )
      end

      # Extracts and raises an error from +xml+, if any.
      def check_error(xml) #:nodoc:
        if error = Error.parse(xml, :single => true)
          raise Graticule::Error, error.message
        end
      end

      # Creates a URL from the Hash +params+.  Automatically adds the appid and
      # sets the output type to 'xml'.
      def make_url(params) #:nodoc:
        params[:appid] = @appid
        params[:output] = 'xml'

        super params
      end

    end
    
  end
end