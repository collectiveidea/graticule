module Graticule #:nodoc:
  
  # Yahoo geocoding API.
  #
  # http://developer.yahoo.com/maps/rest/V1/geocode.html
  class YahooGeocoder < RestGeocoder

    PRECISION = {
      "country"=> :country,
      "state" => :state,
      "city" => :city,
      "zip+4" => :zip,
      "zip+2" => :zip,
      "zip" => :zip,
      "street" => :street,
      "address" => :address
    }

    # Web services initializer.
    #
    # The +appid+ is the Application ID that uniquely identifies your
    # application.  See: http://developer.yahoo.com/faq/index.html#appid
    #
    # Concrete web services implementations need to set the following instance
    # variables then call super:
    #
    # +host+:: API endpoint hostname
    # +service_name+:: service name
    # +version+:: service name version number
    # +method+:: service method call
    #
    # See http://developer.yahoo.com/search/rest.html
    def initialize(appid)
      @host = 'api.local.yahoo.com'
      @service_name = 'MapsService'
      @version = 'V1'
      @method = 'geocode'
      @appid = appid
      @url = URI.parse "http://#{@host}/#{@service_name}/#{@version}/#{@method}"
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
      # yahoo pukes on line breaks
      get :location => address.gsub("\n", ', ')
    end

    def parse_response(xml) # :nodoc:
      locations = []

      xml.elements['ResultSet'].each do |r|
        location = Location.new

        location.precision = PRECISION[r.attributes['precision']] || :unknown

        if r.attributes.include? 'warning' then
          location.warning = r.attributes['warning']
        end

        location.latitude = r.elements['Latitude'].text.to_f
        location.longitude = r.elements['Longitude'].text.to_f

        location.street = r.elements['Address'].text.titleize unless r.elements['Address'].text.blank?
        location.locality = r.elements['City'].text.titleize unless r.elements['City'].text.blank?
        location.region = r.elements['State'].text
        location.postal_code = r.elements['Zip'].text
        location.country = r.elements['Country'].text

        locations << location
      end

      # FIXME: make API consistent and only return 1 location
      return locations
    end

    # Extracts and raises an error from +xml+, if any.
    def check_error(xml) #:nodoc:
      err = xml.elements['Error']
      raise Error, err.elements['Message'].text if err
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