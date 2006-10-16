
module Geocode

  # Library for looking up coordinates with MetaCarta's GeoParser API.
  #
  # http://labs.metacarta.com/GeoParser/documentation.html
  class MetaCartaGeocoder < RestGeocoder
    Location = Struct.new :name, :type, :population, :hierarchy,
                          :latitude, :longitude, :confidence, :viewbox

    def initialize # :nodoc:
      @url = URI.parse 'http://labs.metacarta.com/GeoParser/'
    end

    # Locates +place+ and returns a Location object.
    def locate(place)
      locations, = get :q => place
      return locations.first
    end

    # Retrieve all locations matching +place+.
    #
    # Returns an Array of Location objects and a pair of coordinates that will
    # surround them.
    def locations(place)
      get :loc => place
    end

    def check_error(xml) # :nodoc:
      raise AddressError, 'bad location' unless xml.elements['Locations/Location']
    end

    def make_url(params) # :nodoc:
      params[:output] = 'locations'

      super params
    end

    def parse_response(xml) # :nodoc:
      locations = []

      xml.elements['/Locations'].each do |l|
        next if REXML::Text === l or l.name == 'ViewBox'
        location = Location.new

        location.viewbox = viewbox_coords l.elements['ViewBox/gml:Box/gml:coordinates']

        location.name = l.attributes['Name']
        location.type = l.attributes['Type']
        population = l.attributes['Population'].to_i
        location.population = population > 0 ? population : nil
        location.hierarchy = l.attributes['Hierarchy']

        coords = l.elements['Centroid/gml:Point/gml:coordinates'].text.split ','
        location.latitude = coords.first.to_f
        location.longitude = coords.last.to_f

        confidence = l.elements['Confidence']
        location.confidence = confidence.text.to_f if confidence

        locations << location
      end

      query_viewbox = xml.elements['/Locations/ViewBox/gml:Box/gml:coordinates']

      return locations, viewbox_coords(query_viewbox)
    end

    # Turns a element containing a pair of coordinates into a pair of coordinate
    # Arrays.
    def viewbox_coords(viewbox) # :nodoc:
      return viewbox.text.split(' ').map do |coords|
        coords.split(',').map { |c| c.to_f }
      end
    end

  end

  # A Location contains the following fields:
  #
  # +name+:: The name of this location
  # +type+:: The type of this location (no clue what it means)
  # +population+:: The number of people who live here or nil
  # +hierarchy+:: The places above this place
  # +latitude+:: Latitude of the location
  # +longitude+:: Longitude of the location
  # +confidence+:: Accuracy confidence (if any)
  # +viewbox+:: Pair of coordinates forming a box around this place
  # 
  # viewbox runs from lower left to upper right.
  class MetaCartaGeocoder::Location

    ##
    # The latitude and longitude for this location.

    def coordinates
      [latitude, longitude]
    end

  end

end