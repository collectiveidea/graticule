module Graticule #:nodoc:
  module Geocoder #:nodoc:

    # First you need a Mapquest API key.  You can register for one here:
    # http://www.mapquest.com/features/main.adp?page=developer_tools_oapi
    #
    # Then you create a MapquestGeocode object and start locating addresses:
    #
    #   gg = Graticule.service(:map_quest).new(MAPS_API_KEY)
    #   location = gg.locate :street => '1600 Amphitheater Pkwy', :locality => 'Mountain View', :region => 'CA'
    #   p location.coordinates
    #
    class MapQuest < Rest
      # http://trc.mapquest.com

      PRECISION = {
        0 => :unknown,
        'COUNTRY' => :country,
        'STATE' => :state,
        'COUNTY' => :state,
        'CITY' => :city,
        'ZIP' => :zip,'ZIP7' => :zip,'ZIP9' => :zip,
        'INTERSECTIONS' => :street,
        'STREET' => :street,
        'ADDRESS' => :address
      }

      # Creates a new MapquestGeocode that will use Mapquest API key +key+.
      #
      # WARNING: The MapQuest API Keys tend to be already URI encoded. If this is the case
      # be sure to URI.unescape the key in the call to new
      def initialize(key)
        @key = key
        @url = URI.parse 'http://web.openapi.mapquest.com/oapi/transaction'
      end

      # Locates +address+ returning a Location
      def locate(address)
        get map_attributes(location_from_params(address))
      end

    private

      def map_attributes(location)
        mapping = {:street => :address, :locality => :city, :region => :stateProvince, :postal_code => :postalcoe, :country => :country}
        mapping.keys.inject({}) do |result,attribute|
          result[mapping[attribute]] = location.attributes[attribute] unless location.attributes[attribute].blank?
          result
        end
      end
      
      # Extracts a Location from +xml+.
      def parse_response(xml) #:nodoc:
        address = REXML::XPath.first(xml, '/advantage/geocode/locations/location')

        Location.new \
        :street => value(address.elements['//address/text()']),
        :locality => value(address.elements['//city/text()']),
        :region => value(address.elements['//stateProvince/text()']),
        :postal_code => value(address.elements['//postalCode/text()']),
        :country => value(address.elements['//country/text()']),
        :latitude => value(address.elements['//latitude/text()']),
        :longitude => value(address.elements['//longitude/text()']),
        :precision => PRECISION[address.elements['//geocodeQuality'].text] || :unknown
      end

      # Extracts and raises an error from +xml+, if any.
      def check_error(xml) #:nodoc:
        return unless xml.elements['//error']
        status = xml.elements['//error/code'].text.to_i
        msg = xml.elements['//error/text'].text
        case status
        when 255..299 then
          raise CredentialsError, msg
        when 400..500 then
          raise AddressError, msg
        when 600.699 then
          raise Error, msg
        when 900 then
          raise AddressError, 'invalid latitude'
        when 901 then
          raise AddressError, 'invalid longitude'
        when 902 then
          raise AddressError, 'error parsing params'
        when 9902 then
          raise CredentialsError, 'invalid key'
        when 9904 then
          raise CredentialsError, 'key missing'
        else
          raise Error, "unknown error #{status}: #{msg}"
        end
      end

      # Creates a URL from the Hash +params+.  Automatically adds the key and
      # sets the output type to 'xml'.
      def make_url(params) #:nodoc:
        super params.merge({:key => @key, :transaction => 'geocode', :ambiguities => 0})
      end

      def value(element)
        element.value if element
      end

      def text(element)
        element.text if element
      end
    end
  end
end
