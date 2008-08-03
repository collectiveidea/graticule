require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Graticule
  module Geocoder
    class MultiTest < Test::Unit::TestCase

      def setup
        @mock_geocoders = [mock("geocoder 1"), mock("geocoder 2")]
        @mock_geocoders.each {|g| g.stubs(:locate) }
        @geocoder = Multi.new(*@mock_geocoders)
      end

      def test_locate_calls_each_geocoder_and_raises_error
        @mock_geocoders.each do |g|
          g.expects(:locate).with('test').raises(Graticule::AddressError)
        end
        assert_raises(Graticule::AddressError) { @geocoder.locate 'test' }
      end

      def test_locate_returns_first_result_without_calling_others
        result = mock("result")
        @mock_geocoders.first.expects(:locate).returns(result)
        @mock_geocoders.last.expects(:locate).never
        assert_equal result, @geocoder.locate('test')
      end
      
      def test_locate_with_custom_block
        @mock_geocoders.first.expects(:locate).returns(1)
        @mock_geocoders.last.expects(:locate).returns(2)
        @geocoder = Multi.new(*@mock_geocoders) {|r| r == 2 }
        assert_equal 2, @geocoder.locate('test')
      end

      def test_locate_with_custom_block_and_no_match
        @mock_geocoders.first.expects(:locate).returns(1)
        @mock_geocoders.last.expects(:locate).returns(2)
        @geocoder = Multi.new(*@mock_geocoders) {|r| r == 3 }
        assert_raises(Graticule::AddressError) { @geocoder.locate('test') }
      end

    end
  end
end