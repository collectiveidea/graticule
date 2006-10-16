#!/usr/bin/env ruby
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/mocks')
$:.unshift(File.dirname(__FILE__)+ '/extra')

require 'rubygems'
require 'yaml'
require 'test/unit'
require 'breakpoint'
require 'geocode'

module Test
  module Unit
    module Assertions
      
      private
        def response(geocoder, response)
          clean_backtrace do
            File.read(File.dirname(__FILE__) + "/fixtures/responses/#{geocoder}/#{response}.xml")
          end
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
