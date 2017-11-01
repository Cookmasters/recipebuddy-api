# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests Facebook API' do
  API_VER = 'api/v0.1'.freeze
  CASSETTE_FILE = 'recipe_api'.freeze

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Page information' do
    it 'HAPPY: should provide correct page attributes' do
      get "#{API_VER}/page/#{PAGE_NAME}"
      _(last_response.status).must_equal 200
      page_data = JSON.parse last_response.body
      _(page_data['page']['origin_id']).must_be_instance_of String
      _(page_data['page']['name']).must_be_instance_of String
    end

    it 'SAD: should raise exception on incorrect page' do
      get "#{API_VER}/page/#{BAD_PAGE_NAME}"
      _(last_response.status).must_equal 404
      body = JSON.parse last_response.body
      _(body.keys).must_include 'error'
    end

    it 'HAPPY: should get the recipes from the page' do
      get "#{API_VER}/page/#{PAGE_NAME}/recipes"
      _(last_response.status).must_equal 200
      page_data = JSON.parse last_response.body
      _(page_data['recipes'].count).must_equal 25
    end
  end

  describe 'Recipe videos' do
    it 'HAPPY: should get a recipe videos' do
      get "#{API_VER}/recipe/#{RECIPE_TO_SEARCH}"
      _(last_response.status).must_equal 200
      recipe_data = JSON.parse last_response.body
      _(recipe_data['videos'].count).must_equal 5
    end
  end
end
