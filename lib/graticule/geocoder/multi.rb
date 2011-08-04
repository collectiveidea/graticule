# encoding: UTF-8
require 'timeout'

module Graticule #:nodoc:
  module Geocoder #:nodoc:
    class Multi

      # The Multi geocoder allows you to use multiple geocoders in succession.
      #
      #   geocoder = Graticule.service(:multi).new(
      #     Graticule.service(:google).new("api_key"),
      #     Graticule.service(:yahoo).new("api_key"),
      #   )
      #   geocoder.locate '49423' # <= tries geocoders in succession
      #
      # The Multi geocoder will try the geocoders in order if a Graticule::AddressError
      # is raised.  You can customize this behavior by passing in a block to the Multi
      # geocoder.  For example, to try the geocoders until one returns a result with a
      # high enough precision:
      #
      #   geocoder = Graticule.service(:multi).new(geocoders) do |result|
      #     [:address, :street].include?(result.precision)
      #   end
      #
      # Geocoders will be tried in order until the block returned true for one of the results
      #
      # Use the :timeout option to specify the number of seconds to allow for each
      # geocoder before raising a Timout::Error (defaults to 10 seconds).
      #
      #   Graticule.service(:multi).new(geocoders, :timeout => 3)
      #
      def initialize(*geocoders, &acceptable)
        @options = {:timeout => 10, :async => false}.merge(geocoders.extract_options!)
        @acceptable = acceptable || Proc.new { true }
        @geocoders = geocoders
      end

      def locate(address)
        @lookup = @options[:async] ? ParallelLookup.new : SerialLookup.new
        last_error = nil
        @geocoders.each do |geocoder|
          @lookup.perform do
            begin
              result = nil
              Timeout.timeout(@options[:timeout]) do
                result = geocoder.locate address
              end
              result if @acceptable.call(result)
            rescue => e
              last_error = e
              nil
            end
          end
        end
        @lookup.result || raise(last_error || AddressError.new("Couldn't find '#{address}' with any of the services"))
      end

      class SerialLookup #:nodoc:
        def initialize
          @blocks = []
        end

        def perform(&block)
          @blocks << block
        end

        def result
          result = nil
          @blocks.detect do |block|
            result = block.call
          end
          result
        end
      end

      class ParallelLookup #:nodoc:
        def initialize
          @threads = []
          @monitor = Monitor.new
        end

        def perform(&block)
          @threads << Thread.new do
            self.result = block.call
          end
        end

        def result=(result)
          if result
            @monitor.synchronize do
              @result = result
              @threads.each(&:kill)
            end
          end
        end

        def result
          @threads.each(&:join)
          @result
        end
      end
    end
  end
end