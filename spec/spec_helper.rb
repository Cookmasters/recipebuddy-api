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

PAGE_NAME = 'RecipesAndCookingGuide'.freeze
BAD_PAGE_NAME = 'olcooker'.freeze

BAD_FB_TOKEN = 'hastalavista'.freeze

CORRECT_FACEBOOK = YAML.safe_load(File.read('spec/fixtures/fb_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze

CASSETTE_YOUTUBE_FILE = 'youtube_api'.freeze
CASSETTE_FACEBOOK_FILE = 'facebook_api'.freeze

RECIPE_TO_SEARCH = 'Chicken+and+Broccoli+Stir+fry'.freeze
BAD_RECIPE_TO_SEARCH = 'Chicken and Broccoli Stir fry'.freeze
