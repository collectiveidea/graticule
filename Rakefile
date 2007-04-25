require 'rubygems'
require 'active_support'
require 'hoe'
require File.join(File.dirname(__FILE__), 'lib', 'graticule', 'version.rb')

Hoe.new("graticule", Graticule::Version::STRING) do |p|
  p.rubyforge_name = "graticule"
  p.author = 'Brandon Keepers'
  p.email = 'brandon@opensoul.org'
  p.summary = "API for using all the popular geocoding services."
  p.description = 'Graticule is a geocoding API that provides a common interface to all the popular services, including Google, Yahoo, Geocoder.us, and MetaCarta.'
  p.url = 'http://graticule.rubyforge.org'
  p.need_tar = true
  p.need_zip = true
  p.test_globs = ['test/**/*_test.rb']
  p.changes = p.paragraphs_of('CHANGELOG.txt', 0..1).join("\n\n")
  p.extra_deps << ['activesupport']
end



namespace :test do
  namespace :cache do
    desc 'Cache test responses from all the free geocoders'
    task :free => [:google, :geocoder_us, :host_ip, :local_search_maps, :meta_carta, :yahoo]
    
    desc 'Cache test responses from Google'
    task :google do
      cache_responses('google')
    end
    
    desc 'Cache test responses from Geocoder.us'
    task :geocoder_us do
      cache_responses('geocoder_us')
    end
    
    desc 'Cache test responses from HostIP'
    task :host_ip do
      cache_responses('host_ip')
    end

    desc 'Cache test responses from Local Search Maps'
    task :local_search_maps do
      cache_responses('local_search_maps')
    end

    desc 'Cache test responses from Meta Carta'
    task :meta_carta do
      cache_responses('meta_carta')
    end

    desc 'Cache test responses from Yahoo'
    task :yahoo do
      cache_responses('yahoo')
    end

  end
end

require 'net/http'
require 'uri'
RESPONSES_PATH = File.dirname(__FILE__) + '/test/fixtures/responses'

def cache_responses(service)
  test_config[service.to_s]['responses'].each do |file,url|
    File.open("#{RESPONSES_PATH}/#{service}/#{file}", 'w') do |f|
      f.puts Net::HTTP.get(URI.parse(url))
    end
  end
end

def test_config
  file = File.dirname(__FILE__) + '/test/config.yml'
  raise "Copy config.yml.default to config.yml and set the API keys" unless File.exists?(file)
  @test_config ||= returning(YAML.load(File.read(file))) do |config|
    config.each do |service,values|
      values['responses'].each {|file,url| update_placeholders!(values, url) }
    end
  end
end

def update_placeholders!(config, thing)
  config.each do |option, value|
    thing.gsub!(":#{option}", value) if value.is_a?(String)
  end
end