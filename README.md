# RecipeBuddy API

[ ![Codeship Status for Cookmasters/facebook-graph-api](https://app.codeship.com/projects/e01798b0-ab6c-0135-227f-46ac882f0537/status?branch=master)](https://app.codeship.com/projects/256729)

This is our Service Oriented Architecture project API and aims to aggregate recipes for Facebook public pages/groups and find the relevant videos of the recipes from Youtube.

## Routes

### Application Routes

- GET `/`: main route

### Page Routes

- GET `api/v0.1/page/[pagename]`: returns a json of the page information
- POST `api/v0.1/page/[pagename]`: gets the page information along with the recipes from Facebook and saves it in the database


## Install

Install this API by cloning the *relevant branch* and installing required gems:

    $ bundle install


## Testing

Test this API by running:

    $ RACK_ENV=test rake db:migrate
    $ bundle exec rake spec

## Develop

Run this API during development:

    $ rake db:migrate
    $ bundle exec rackup

or use autoloading during development:

    $ bundle exec rerun rackup
