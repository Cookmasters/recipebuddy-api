# frozen_string_literal: false

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/facebook_api.rb'

PAGE_NAME = 'RecipesAndCookingGuide'.freeze
BAD_PAGE_NAME = 'olcooker'.freeze
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
FB_TOKEN = CONFIG['fb_token']
BAD_FB_TOKEN = 'hastalavista'.freeze
CORRECT = YAML.safe_load(File.read('spec/fixtures/fb_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FILE = 'facebook_api'.freeze
