# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'graticule/version'

Gem::Specification.new do |s|
  s.name = %q{graticule}
  s.version = Graticule::VERSION
  s.authors = ["Brandon Keepers", "Daniel Morrison"]
  s.default_executable = %q{geocode}
  s.description = %q{Graticule is a geocoding API that provides a common interface to all the popular services, including Google, Yahoo, Geocoder.us, and MetaCarta.}
  s.email = %q{brandon@opensoul.org}
  s.executables = ["geocode"]
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = Dir.glob("{bin,lib}/**/*") + %w(CHANGELOG.txt LICENSE.txt README.txt)
  s.homepage = %q{http://github.com/collectiveidea/graticule}
  s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{graticule}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{API for using all the popular geocoding services.}

  s.add_runtime_dependency 'activesupport', '~>3.0'
  s.add_runtime_dependency 'i18n'
  s.add_runtime_dependency 'happymapper',   '>= 0.3.0'
  s.add_development_dependency 'mocha' 
  s.add_development_dependency 'rcov' 
end

