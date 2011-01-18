$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
# require 'rubygems'
require 'bundler/setup'
require 'graticule/version'
require 'active_support'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

desc 'Default: run unit tests.'
task :default => :test

task :build do
  system "gem build graticule.gemspec"
end
 
task :release => :build do
  system "gem push graticule-#{Graticule::VERSION}.gem"
end

task :install => :build do
  system "gem install graticule-#{Graticule::VERSION}.gem"
end

desc 'Run the unit tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentatio'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Graticule'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.txt')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :test do
  desc "just rcov minus html output"
  Rcov::RcovTask.new(:coverage) do |t|
    # t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.output_dir = 'coverage'
    t.verbose = true
    t.rcov_opts = %w(--exclude test,/usr/lib/ruby,/Library/Ruby,$HOME/.gem --sort coverage)
  end
end

require 'active_support'
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
  @test_config ||= YAML.load(File.read(file)).tap do |config|
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

namespace :test do
  namespace :cache do
    desc 'Cache test responses from all the geocoders'
    task :all => test_config.keys

    test_config.keys.each do |service|
      desc "Cache test responses for #{service}"
      task service do
        cache_responses(service)
      end
    end
  end
end

