
module Geocode
  
  # The Geocode class is the base class for all geocoder implementations. The
  # geocoders must implement:
  # 
  #  * authorize(money, creditcard, options = {})
  #  * purchase(money, creditcard, options = {})
  #  * capture(money, authorization, options = {})
  #  * credit(money, identification, options = {})  
  #  * recurring(money, identification, options = {})  
  #  * store(money, identification, options = {})  
  #  * unstore(money, identification, options = {})  
  #  
  
  class Geocoder
    def initialize
      raise NotImplementedError
    end
    
    def self.service(name)
      Geocode.const_get "#{name}_geocoder".camelize
    end
  end
end