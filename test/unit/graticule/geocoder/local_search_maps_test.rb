require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class LocalSearchMapsTest < Test::Unit::TestCase
      
      def setup
        @geocoder = LocalSearchMaps.new
        URI::HTTP.responses = []
        URI::HTTP.uris = []
      end
      
      def test_success
        prepare_response :success
        
        location = Location.new :latitude => 51.510036, :longitude => -0.130427
        
        assert_equal location, @geocoder.locate(:street => '48 Leicester Square',
          :locality => 'London', :country => 'UK')
      end

    private
    
      def prepare_response(id = :success)
        URI::HTTP.responses << response('local_search_maps', id, 'txt')
      end
      
    end
  end
end