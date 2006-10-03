#!/usr/bin/env ruby
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/mocks')
$:.unshift(File.dirname(__FILE__)+ '/extra')

require 'rubygems'
require 'yaml'
require 'test/unit'
require 'geocode'

module Test
  module Unit
    module Assertions
      
      private
        def response(geocoder, response)
          REXML::Document.new(File.read(File.dirname(__FILE__) + "/fixtures/responses/#{geocoder}/#{response}.xml"))
        end
      
        def clean_backtrace(&block)
          yield
        rescue AssertionFailedError => e
          path = File.expand_path(__FILE__)
          raise AssertionFailedError, e.message, e.backtrace.reject { |line| File.expand_path(line) =~ /#{path}/ }
        end
    end
  end
end
