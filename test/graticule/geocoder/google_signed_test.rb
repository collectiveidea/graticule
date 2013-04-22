# encoding: UTF-8
require 'test_helper'

class GoogleTest < Test::Unit::TestCase
  def test_url_is_signed_for_business_accounts
    geocoder = Graticule.service(:google).new("e7-fake-account-R911GuLecpVqA=", 'gme-example')
    url = geocoder.send :make_url, :address => 'New York'
    expected = "http://maps.googleapis.com/maps/api/geocode/json?address=New%20York&client=gme-example&sensor=false&signature=EJNTEh9SqstO1FLcbFsQ0aJrWHA="
    assert_equal expected, url.to_s
  end

  def test_url_is_not_signed_for_normal_accounts
    geocoder = Graticule.service(:google).new()
    url = geocoder.send :make_url, :address => 'New York'
    expected = "http://maps.googleapis.com/maps/api/geocode/json?address=New%20York&sensor=false"
    assert_equal expected, url.to_s
  end
end

