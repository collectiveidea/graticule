require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

module Graticule
  module Geocoder
    class MapquestTest < Test::Unit::TestCase
      def setup
        @geocoder = Mapquest.new('client_id', 'password')
      end

      def test_success
        prepare_response(:success)
        location = Location.new(
          :country => "US",
          :latitude => 44.152019,
          :locality => "Lovell",
          :longitude => -70.892706,
          :postal_code => "04051-3919",
          :precision => :address,
          :region => "ME",
          :street => "44 Allen Rd"
        )
        assert_equal(location, @geocoder.locate('44 Allen Rd., Lovell, ME 04051'))
      end

      def test_multi_result
        prepare_response(:multi_result)
        location = Location.new(
          :country => "US",
          :latitude => 40.925598,
          :locality => "Stony Brook",
          :longitude => -73.141403,
          :postal_code => nil,
          :precision => :city,
          :region => "NY",
          :street => nil
        )
        assert_equal(location, @geocoder.locate('217 Union St., NY'))
      end

      protected
      
      def prepare_response(id)
        URI::HTTP.responses << response('mapquest', id)
      end
    end
  end
end
