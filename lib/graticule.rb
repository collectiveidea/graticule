$:.unshift(File.dirname(__FILE__))      

require 'graticule/location'
require 'graticule/geocoder'
require 'graticule/geocoders/bogus'
require 'graticule/geocoders/rest'
require 'graticule/geocoders/google'
require 'graticule/geocoders/yahoo'
require 'graticule/geocoders/geocoder_us'
require 'graticule/geocoders/meta_carta'
require 'graticule/distance'
require 'graticule/distance/haversine'
require 'graticule/distance/spherical'
require 'graticule/distance/vincenty'
