require 'optparse'

module Graticule
  class Cli
    
    def self.start
      options = { :service => :yahoo, :api_key => 'YahooDemo' }
      
      OptionParser.new do |opts|
        opts.banner = "Usage: geocode [options] location"
        opts.separator ""
        opts.separator "Options: "

        opts.on("-s service", %w(yahoo google geocoder_us metacarta), "--service service", "Geocoding service") do |service|
          options[:service] = service
        end
        
        opts.on("-a apikey", "--apikey apikey", "API key for the selected service")
        
        opts.on_tail("-h", "--help", "Help") do
          puts opts
          exit
        end
      end.parse!
      
      options[:location] = ARGV.join(" ")
      
      result = Graticule.service(options[:service]).new(options[:api_key]).locate(options[:location])
      location = (result.is_a?(Array) ? result.first : result)
      if location
        puts location.to_s(true)
      else
        puts "Location not found"
      end
    rescue OptionParser::InvalidArgument => error
      $stderr.puts error.message
    rescue OptionParser::InvalidOption => error
      $stderr.puts error.message
    rescue Graticule::CredentialsError
      $stderr.puts "Invalid API key. Pass your #{options[:service]} API key using the -a option. "
    end
    
    
  end
end

