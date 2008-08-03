# account code: INDIV30777
# license key: KG39-HM17-PZ95-NR98
require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class PostcodeAnywhereTest < Test::Unit::TestCase

      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = PostcodeAnywhere.new 'account_code', 'license_key'
      end

    def test_locate
      prepare_response(:success)
      location = Location.new(
        :street => "204 Campbell Ave",
        :locality => "Revelstoke",
        :region => "BC",
        :postal_code => "V0E",
        :country => "Canada",
        :longitude => -118.196970002204,
        :latitude => 50.9997350418267
      )
      assert_equal location, @geocoder.locate(:street => "204 Campbell Ave",
        :locality => "Revelstoke", :country => "Canada")
    end
    
    def test_locate_uk_address
      prepare_response(:uk)
      
      location = Location.new :latitude => 51.5728910186362, :longitude => -0.253788666693255
      assert_equal location, @geocoder.locate(:street => '80 Wood Lane', :locality => 'London', :country => 'UK')
    end
    
    def test_empty
      prepare_response(:empty)
      
      assert_raises(Graticule::AddressError) { @geocoder.locate :street => 'foobar'}
    end
  
    protected
      def prepare_response(id)
        URI::HTTP.responses << response('postcode_anywhere', id)
      end
  
    end
  end
end