# encoding: utf-8

require File.expand_path("../lib/graticule/version.rb", __FILE__)

Gem::Specification.new do |spec|
  spec.name    = "graticule"
  spec.version = Graticule::VERSION

  spec.authors     = ["Brandon Keepers", "Daniel Morrison"]
  spec.email       = ["brandon@opensoul.org", "daniel@collectiveidea.com"]
  spec.description = "Graticule is a geocoding API that provides a common interface to all the popular services, including Google, Yahoo, Geocoder.us, and MetaCarta."
  spec.summary     = "API for using all the popular geocoding services"
  spec.homepage    = "https://github.com/collectiveidea/graticule"
  spec.license     = "MIT"

  spec.files         = `git ls-files`.split($\)
  spec.test_files    = spec.files.grep(/^test/)
  spec.executables   = ["geocode"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "i18n"
  spec.add_dependency "happymapper", ">= 0.3.0"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.0"
end

