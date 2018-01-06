# RecipeBuddy API

[ ![Codeship Status for Cookmasters/recipebuddy-api](https://app.codeship.com/projects/e01798b0-ab6c-0135-227f-46ac882f0537/status?branch=master)](https://app.codeship.com/projects/256729)

This is our Service Oriented Architecture project API and aims to aggregate recipes for Facebook public pages and find the relevant videos of the recipes from YouTube.

## Routes

### Application Routes

- GET `/`: main route


### Page Routes

- GET `api/v0.1/page/all`: returns a json of all the Facebook pages along with the recipes already saved in the database
- GET `api/v0.1/page/[pagename]`: returns a json of the page information along with the recipes of that page
- POST `api/v0.1/page/[pagename]`: gets the page information along with the recipes from Facebook and saves it in the database
- PUT `api/v0.1/page/[pagename]`: deletes the current recipes of the page and runs a request (background worker) to get the most recent recipes of that page

### Recipe Routes

- GET `api/v0.1/recipe/all`: returns a json of all the recipes already saved in the database
- GET `api/v0.1/recipe/best`: returns a json of the best 150 recipes ordered by the number of positive reactions on Facebook(like, love, wow, haha)
- GET `api/v0.1/recipe/[id]`: returns a json of the recipe


## Install

Install this API by cloning the *relevant branch* and installing required gems:

    $ git clone git@github.com:Cookmasters/recipebuddy-api.git
    $ cd recipebuddy-api
    $ bundle install

You may have to add your Facebook access and AWS token to `config/secrets.yml` (see example in folder).
Also don't forget to configure the AWS queues in `config/app.yml` and `workers/shoryuken.yml`, `workers/shoryuken_dev.yml`, `workers/shoryuken_test.yml`

## Testing

Test this API by running:

    $ RACK_ENV=test rake db:migrate
    $ bundle exec rake spec

## Develop

Run this API during development:

    $ rake db:migrate
    $ bundle exec rake api:run:dev

## Background Worker

Loads the recipes in the background. Run it with the following command:

    $ rake worker:run:<environment>

Environment can take one of the following values *dev, test, production*

## Rake tasks available

Run the following task to find more Rake tasks:

    $ rake -T
