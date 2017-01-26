# Belvedere

## What is this

Belvedere is an application for generating graphs from event data stored by Segment in Redshift.  It's meant as a replacement for certain Mixpanel functionality, which we find slows load time and is expensive.

## Why Belvedere?

#### bel·ve·dere
ˈbelvəˌdir/

_noun_

      a summerhouse or open-sided gallery, usually at rooftop level, commanding a fine view.

## Set up

```
# install node packages
npm install

# install ruby packages
bundle install

# set up your environemnt
mv .env.example # and fill this in

# run the sinatra app
dotenv ruby app.rb

# hot reloading

# browserify
npm install watchify
watchify web/src/js/index.js -o web/public/js/index.js

# sass
sass --watch web/src:web/public

# sinatra
dotenv rerun ruby app.rb

## TODO

So much.
