= Graticule

Graticule is a geocoding API for looking up address coordinates.  It supports many popular APIs, including Yahoo, Google, Geocoder.ca, Geocoder.us, PostcodeAnywhere and MetaCarta.

= Usage

  require 'rubygems'
  require 'graticule'
  geocoder = Graticule.service(:google).new "api_key"
  location = geocoder.locate "61 East 9th Street, Holland, MI"

= Distance Calculation

Graticule includes 3 different distance formulas, Spherical (simplest but least accurate), Vincenty (most accurate and most complicated), and Haversine (somewhere inbetween).

  geocoder.locate("Holland, MI").distance_to(geocoder.locate("Chicago, IL"))
  #=> 101.997458788177
  
= Command Line

Graticule includes a command line interface (CLI).

  $ geocode -s yahoo -a yahookey Washington, DC
  Washington, DC US
  latitude: 38.895222, longitude: -77.036758

= How to contribute

If you find what you might think is a bug:

1. Check the GitHub issue tracker to see if anyone else has had the same issue.
   http://github.com/collectiveidea/graticule/issues/
2. If you don't see anything, create an issue with information on how to reproduce it.

If you want to contribute an enhancement or a fix:

1. Fork the project on github.
   http://github.com/collectiveidea/graticule/
2. Make your changes with tests.
3. Commit the changes without making changes to the Rakefile, VERSION, or any other files that aren't related to your enhancement or fix
4. Send a pull request.
