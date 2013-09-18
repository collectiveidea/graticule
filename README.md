Graticule
=========

```
  grat·i·cule |ˈgratəˌkyoōl|
    Navigation. a network of parallels and meridians on a map or chart.
```

Graticule is a geocoding API for looking up address coordinates and performing distance calculations. It supports many popular APIs:

* Yahoo
* Google
* MapQuest
* Geocoder.ca
* Geocoder.us
* Geonames
* SimpleGeo
* Postcode Anywhere
* MetaCarta
* FreeThePostcode
* LocalSearchMaps
* Yandex

### Installation

```
gem install graticule
```

### Usage

There is a companion Rails plugin called [acts_as_geocodable](https://github.com/collectiveidea/acts_as_geocodable) that makes geocoding seem like magic.

Graticule exposes to main APIs: location search and distance calculations. Graticule also
provides a command line utility.

#### Location Search / Geocoding

```
require 'rubygems'
require 'graticule'

geocoder = Graticule.service(:google).new "api_key"
location = geocoder.locate("61 East 9th Street, Holland, MI")
```

For specific service documentation, please visit the [RDOCS -- rdoc.info link].

#### Distance Calculation

Graticule includes 3 different distance formulas, Spherical (simplest but least accurate), Vincenty (most accurate and most complicated), and Haversine (somewhere inbetween). The default is Haversine. There are two ways to calculate the distance between two points.

First is `Location#distance_to`:

```
holland = geocoder.locate("Holland, MI")
chicago = geocoder.locate("Chicago, IL")
holland.distance_to(chicago, :formula => :haversine) # or :spherical or :vincenty
# => 101.997458788177
```

You can also use the formula classes directly:

```
Graticule::Distance::Haversine.distance(holland, chicago)
# => 101.997458788177
```

All units are miles by default, but you can switch to kilometers with the `units` option

```
holland.distance_to(chicago, :units => :kilometers)
#
Graticule::Distance::Haversine.distance(holland, chicago, :kilometers)
```


#### Command Line

Graticule includes a command line interface (CLI).

```
$ geocode -s google -a [api_key] Washington, DC
Washington, DC US
latitude: 38.895222, longitude: -77.036758
```

### Contributing

In the spirit of [free software](http://www.fsf.org/licensing/essays/free-sw.html), **everyone** is encouraged to help improve this project.

Here are some ways you can contribute:

* Reporting bugs
* Suggesting new features
* Writing or editing documentation
* Writing specifications
* Writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* Refactoring code
* Reviewing patches

### Submitting an Issue

We use the [GitHub issue tracker](https://github.com/collectiveidea/graticule/issues) to track bugs and features. Before submitting a bug report or feature request, check to make sure it hasn't already been submitted. When submitting a bug report, please include a [Gist](https://gist.github.com/) that includes a stack trace and any details that may be necessary to reproduce the bug, including your gem version, Ruby version, and operating system. 

### Submitting a Pull Request

1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add specs for your feature or bug fix.
5. Run `rake`. If your changes are not 100% covered and passing, go back to step 4.
6. Commit and push your changes.
7. Submit a pull request. Please do not include changes to the gemspec, version, or history file. (If you want to create your own version for some reason, please do so in a separate commit.)

### Other Links

[Blog posts about Graticule](http://opensoul.org/tags/geocoding)

[Geocoder: Alternative Geocoding library](https://github.com/alex.../geocoder)


