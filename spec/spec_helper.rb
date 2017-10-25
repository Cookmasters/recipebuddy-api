# frozen_string_literal: false

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/facebook_api.rb'
require_relative '../lib/youtube_api.rb'
require_relative '../entities/page.rb'
require_relative '../entities/recipe.rb'
require_relative '../lib/mappers/page_mapper.rb'
require_relative '../lib/mappers/recipe_mapper.rb'


PAGE_NAME = 'RecipesAndCookingGuide'.freeze
BAD_PAGE_NAME = 'olcooker'.freeze
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
FB_TOKEN = CONFIG['fb_token']
YT_TOKEN = CONFIG['yt_token']
BAD_FB_TOKEN = 'hastalavista'.freeze
CORRECT = YAML.safe_load(File.read('spec/fixtures/fb_results.yml'))
CORRECT_FACEBOOK = YAML.safe_load(File.read('spec/fixtures/yt_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FACEBOOK_FILE = 'facebook_api'.freeze
CASSETTE_YOUTUBE_FILE = 'youtube_api'.freeze

RECIPE_TO_SEARCH = 'Chicken+and+Broccoli+Stir+fry'.freeze
BAD_RECIPE_TO_SEARCH = 'Chicken and Broccoli Stir fry'.freeze
