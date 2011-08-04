# encoding: UTF-8
require 'test_helper'

module Graticule
  class PrecisionTest < Test::Unit::TestCase
    def test_constants_exist
      %w(
        Unknown
        Country
        Region
        Locality
        PostalCode
        Street
        Address
        Premise
      ).each do |const|
        assert Precision.const_defined?(const), "Can't find #{const}"
      end
    end
    
    def test_can_compare_precisions
      assert Precision::Country < Precision::Region
      assert Precision::Country > Precision::Unknown
      assert Precision::Country == Precision::Country
      assert Precision::Country == Precision.new(:country)
      assert Precision::Country != Precision::Premise
    end
    
    def test_can_compare_against_symbols
      assert Precision::Country < :region
    end
    
    def test_can_compare_against_symbols
      assert_raise(ArgumentError) { Precision::Unknown > :foo }
      assert_raise(ArgumentError) { Precision::Unknown == :bar }
    end
  end
end