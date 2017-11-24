# frozen_string_literal: false

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative 'test_load_all'

load 'Rakefile'
Rake::Task['db:reset'].invoke

ROUTE_RECIPES = 'recipes'.freeze
BAD_ROUTE_RECIPES = 'recipe/roasted'.freeze
CORRECT_YUMMLY = YAML.safe_load(File.read('spec/fixtures/yl_results.yml'))
CORRECT_YUMMLY_RECIPES = CORRECT_YUMMLY['recipes']
RECIPE_TO_SEARCH = 'Cranberry+Orange+Sauce'.freeze

PAGE_NAME = 'RecipesAndCookingGuide'.freeze
BAD_PAGE_NAME = 'olcooker'.freeze

BAD_TOKEN = 'hastalavista'.freeze

CORRECT_FACEBOOK = YAML.safe_load(File.read('spec/fixtures/fb_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze

CASSETTE_YOUTUBE_FILE = 'youtube_api'.freeze
CASSETTE_YUMMLY_FILE = 'yummly_api'.freeze

BAD_RECIPE_TO_SEARCH = 'Chicken and Broccoli Stir fry'.freeze
