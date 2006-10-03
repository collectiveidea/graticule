require File.dirname(__FILE__) + '/../../test_helper'

module Geocode
  class GoogleGeocoderTest < Test::Unit::TestCase
    
    def setup
      @geocoder = GoogleGeocoder.new(:key => "ABQIAAAAs9tdj1TSlnQYVEUc7eOZBBTMhaZ3brwAYOHXggjb6R5ZpwOXhBSZEliaDaesKNzQO1an9CTPpM4KNA")
    end
    
    def test_geocode
      #puts @geocoder.locate("87 E 14th St #4\n49423").inspect
    end
    
    def test_parse_xml
      location = @geocoder.parse_xml()
    end
    
  end
end