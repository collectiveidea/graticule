module Graticule #:nodoc:
  module Geocoder #:nodoc:
    # Bogus geocoder that can be used for test purposes
    class Bogus
      # A queue of canned responses
      class_attribute :responses
      self.responses = []
      
      # A default location to use if the responses queue is empty
      class_inheritable_accessor :default
      
      def locate(address)
        responses.shift || default || Location.new(:street => address)
      end
    end
  end
end
