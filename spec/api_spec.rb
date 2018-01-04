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
    before do
      app.db[:videos].delete
      app.db[:recipes].delete
      app.db[:pages].delete
    end

    describe 'POSTting to create entities from Facebook' do
      it 'HAPPY: should retrieve and store page and recipes' do
        post "#{API_VER}/page/#{PAGE_NAME}"
        _(last_response.status).must_equal 201
        _(last_response.header['Location'].size).must_be :>, 0
        page_data = JSON.parse last_response.body
        _(page_data['origin_id']).must_be_instance_of String
        _(page_data['name']).must_be_instance_of String
      end

      it 'SAD: should report error if no page found' do
        post "#{API_VER}/page/#{BAD_PAGE_NAME}"
        _(last_response.status).must_equal 400
      end
      it 'BAD: should report error if duplicate facebook page found' do
        post "#{API_VER}/page/#{PAGE_NAME}"
        _(last_response.status).must_equal 201
        post "#{API_VER}/page/#{PAGE_NAME}"
        _(last_response.status).must_equal 409
      end
    end

    describe 'GETing database entities' do
      before do
        post "#{API_VER}/page/#{PAGE_NAME}"
      end
      it 'HAPPY: should find stored page and recipes' do
        get "#{API_VER}/page/#{PAGE_NAME}"
        _(last_response.status).must_equal 200
        page_data = JSON.parse last_response.body
        _(page_data['origin_id']).must_be_instance_of String
        _(page_data['name']).must_be_instance_of String
      end

      it 'SAD: should report error if no database page entity found' do
        get "#{API_VER}/page/#{BAD_PAGE_NAME}"
        _(last_response.status).must_equal 404
      end
    end
  end

  describe 'GETing recipes entities' do
    before do
      delete "#{API_VER}/recipe"
      post "#{API_VER}/page/#{PAGE_NAME}"
    end

    it 'HAPPY: should get the best recipes' do
      get "#{API_VER}/recipe/best"
      _(last_response.status).must_equal 200
      best_recipes = JSON.parse last_response.body
      _(best_recipes.count).must_be :>=, 0
    end

    it 'HAPPY: should get all the recipes' do
      # HAPPY: should get all the recipes
      get "#{API_VER}/recipe/all"
      _(last_response.status).must_equal 200
      all_recipes = JSON.parse last_response.body
      _(all_recipes.count).must_be :>=, 0

      # HAPPY: should get the recipe by ID
      recipe = all_recipes['recipes'][0]
      get "#{API_VER}/recipe/#{recipe['id']}"
      _(last_response.status).must_equal 200
      recipe_data = JSON.parse last_response.body
      _(recipe_data['id']).must_equal recipe['id']
      _(recipe_data['created_time']).must_equal recipe['created_time']
      _(recipe_data['content']).must_equal recipe['content']
      _(recipe_data['origin_id']).must_equal recipe['origin_id']
      _(recipe_data['reactions_like']).must_equal recipe['reactions_like']
      _(recipe_data['reactions_love']).must_equal recipe['reactions_love']
      _(recipe_data['reactions_wow']).must_equal recipe['reactions_wow']
      _(recipe_data['reactions_haha']).must_equal recipe['reactions_haha']
      _(recipe_data['reactions_angry']).must_equal recipe['reactions_angry']
      _(recipe_data['reactions_sad']).must_equal recipe['reactions_sad']
      _(recipe_data['full_picture']).must_equal recipe['full_picture']
    end
  end
end
