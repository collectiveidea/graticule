# account code: INDIV30777
# license key: KG39-HM17-PZ95-NR98
require File.dirname(__FILE__) + '/../../../test_helper'

module Graticule
  class PostcodeAnywhereTest < Test::Unit::TestCase

    def setup
      URI::HTTP.responses = []
      URI::HTTP.uris = []
      @geocoder = PostcodeAnywhereGeocoder.new 'account_code', 'license_key'
      @location = Location.new(
        :longitude => -0.0854449407946831,
        :latitude => 51.5261963140527,
        :postal_code => 'N1 6DX'
      )
    end

  def test_locate
    prepare_response(:success)
    assert_equal @location, @geocoder.locate('701 First Street, Sunnyvale, CA')
  end
  
  protected
    def prepare_response(id)
      URI::HTTP.responses << response('postcode_anywhere', id)
    end
  
  end

end