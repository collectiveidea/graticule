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
      def initialize(*geocoders, &acceptable)
        @acceptable = acceptable || lambda { true }
        @geocoders = geocoders.flatten
      end
      
      def locate(address)
        last_error = nil
        @geocoders.each do |geocoder|
          begin
            result = geocoder.locate address
            return result if @acceptable.call(result)
          rescue Error => e
            last_error = e
          rescue Errno::ECONNREFUSED
            logger.error("Connection refused to #{service}")
          end
        end
        raise last_error || AddressError.new("Couldn't find '#{address}' with any of the services")
      end
      
    end
  end
end