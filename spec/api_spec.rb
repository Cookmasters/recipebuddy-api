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
  #
  # describe 'Recipe videos' do
  #   it 'HAPPY: should get a recipe videos' do
  #     get "#{API_VER}/recipe/#{RECIPE_TO_SEARCH}"
  #     _(last_response.status).must_equal 200
  #     recipe_data = JSON.parse last_response.body
  #     _(recipe_data['videos'].count).must_equal 5
  #   end
  # end
end
