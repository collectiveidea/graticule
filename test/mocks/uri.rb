require 'uri/http'
require 'open-uri'

##
# This stub overrides OpenURI's open method to allow programs that use OpenURI
# to be easily tested.
#
# == Usage
#
#   require 'rc_rest/uri_stub'
#   
#   class TestMyClass < Test::Unit::TestCase
#     
#     def setup
#       URI::HTTP.responses = []
#       URI::HTTP.uris = []
#       
#       @obj = MyClass.new
#     end
#     
#     def test_my_method
#       URI::HTTP.responses << 'some text open would ordinarily return'
#       
#       result = @obj.my_method
#       
#       assert_equal :something_meaninfgul, result
#       
#       assert_equal true, URI::HTTP.responses.empty?
#       assert_equal 1, URI::HTTP.uris.length
#       assert_equal 'http://example.com/path', URI::HTTP.uris.first
#     end
#     
#  end

class URI::HTTP # :nodoc:

  class << self
    attr_accessor :responses, :uris
  end

  alias original_open open

  def open(*args)
    self.class.uris << self.to_s
    io = StringIO.new(self.class.responses.shift)
    OpenURI::Meta.init(io)
    yield io if block_given?
    io
  end

end

