# encoding: UTF-8
module Graticule

  # Used to compare the precision of different geocoded locations
  class Precision
    include Comparable
    attr_reader :name

    NAMES = [
      :point,
      :unknown,
      :country,
      :region,
      :locality,
      :postal_code,
      :street,
      :address,
      :premise
    ]

    def initialize(name)
      @name = name.to_sym
      raise ArgumentError, "#{name} is not a valid precision. Use one of #{NAMES.inspect}" unless NAMES.include?(@name)
    end

    Unknown    = Precision.new(:unknown)
    Point      = Precision.new(:point)
    Country    = Precision.new(:country)
    Region     = Precision.new(:region)
    Locality   = Precision.new(:locality)
    PostalCode = Precision.new(:postal_code)
    Street     = Precision.new(:street)
    Address    = Precision.new(:address)
    Premise    = Precision.new(:premise)

    def to_s
      @name.to_s
    end

    def <=>(other)
      other = Precision.new(other) unless other.is_a?(Precision)
      NAMES.index(self.name) <=> NAMES.index(other.name)
    end

    def ==(other)
      (self <=> other) == 0
    end
  end
end
