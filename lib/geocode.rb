
$:.unshift(File.dirname(__FILE__))      

require 'active_support' 

require 'geocode/location'
require 'geocode/geocoder'
require 'geocode/geocoders/bogus'
require 'geocode/geocoders/rest'
require 'geocode/geocoders/google'
require 'geocode/geocoders/yahoo'
require 'geocode/geocoders/geocoder_us'
require 'geocode/geocoders/meta_carta'
