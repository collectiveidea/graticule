
$:.unshift(File.dirname(__FILE__))      

require 'active_support' 

require 'geocode/location'
require 'geocode/geocoder'
require 'geocode/geocoders/bogus'
require 'geocode/geocoders/rest'
require 'geocode/geocoders/google'
require 'geocode/geocoders/yahoo'
