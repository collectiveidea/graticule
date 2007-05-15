require 'graticule'
require 'optparse'

module Graticule
  
  # A command line interface for geocoding.  From the command line, run:
  #
  #   geocode 49423 
  #
  # Outputs:
  #
  #   # Holland, MI 49423 US
  #   # latitude: 42.7654, longitude: -86.1085
  #
  # == Usage: geocode [options] location
  # 
  # Options: 
  #     -s, --service service            Geocoding service
  #     -a, --apikey apikey              API key for the selected service
  #     -h, --help                       Help
  class Cli
    
    def self.start(args, out = STDOUT)
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
      end.parse! args

      options[:location] = args.join(" ")
      
      result = Graticule.service(options[:service]).new(*options[:api_key].split(',')).locate(options[:location])
      location = (result.is_a?(Array) ? result.first : result)
      if location
        out << location.to_s(:coordinates => true)
        exit 0
      else
        out << "Location not found"
        exit 1
      end
    rescue Graticule::CredentialsError
      $stderr.puts "Invalid API key. Pass your #{options[:service]} API key using the -a option. "
    rescue OptionParser::InvalidArgument, OptionParser::InvalidOption,
        Graticule::Error => error
      $stderr.puts error.message
    end
    
    
  end
end

