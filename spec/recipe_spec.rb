# frozen_string_literal: false

require_relative 'spec_helper.rb'
require 'econfig'

describe 'Tests YUMMLY API library' do
  extend Econfig::Shortcut

  Econfig.env = 'development'
  Econfig.root = '.'

  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    YUMMLY_ID = app.config.YUMMLY_ID
    YUMMLY_KEY = app.config.YUMMLY_KEY
    c.filter_sensitive_data('<YUMMLY_ID>') { YUMMLY_ID }
    c.filter_sensitive_data('<YUMMLY_ID_ESC>') { CGI.escape(YUMMLY_ID) }
    c.filter_sensitive_data('<YUMMLY_KEY>') { YUMMLY_KEY }
    c.filter_sensitive_data('<YUMMLY_KEY_ESC>') { CGI.escape(YUMMLY_KEY) }
  end

  before do
    VCR.insert_cassette CASSETTE_YUMMLY_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Recipe information' do
    before do
      recipe_mapper = RecipeBuddy::Yummly::RecipeMapper.new(app.config)
      @recipes = recipe_mapper.load_several(ROUTE_RECIPES)
    end

    it 'HAPPY: should provide correct recipe attributes' do
      recipe = @recipes[0]
      _(recipe.origin_id).must_be_instance_of String
      _(recipe.name).must_be_instance_of String
      _(recipe.rating).must_be_instance_of Integer
      _(recipe.rating).must_be :>=, 0
      _(recipe.total_time_in_seconds).must_be_instance_of Integer
      _(recipe.total_time_in_seconds).must_be :>, 0
      _(recipe.flavors).must_be_instance_of Hash
      _(recipe.categories).must_be_instance_of Array
      _(recipe.likes).must_be :>=, 0
      _(recipe.dislikes).must_be :>=, 0
      _(recipe.number_of_servings).must_be :>=, 0
      _(recipe.ingredients).must_be_instance_of Array
      _(recipe.images).must_be_instance_of Array
    end

    it 'HAPPY: should check recipes' do
      _(@recipes.count).must_equal CORRECT_YUMMLY_RECIPES.count
    end

    it 'SAD: should raise exception on incorrect recipe id' do
      proc do
        recipe_mapper = RecipeBuddy::Yummly::RecipeMapper.new(app.config)
        recipe_mapper.load_several(BAD_ROUTE_RECIPES)
      end.must_raise Errors::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        require 'ostruct'
        sad_config = OpenStruct.new(YUMMLY_KEY: 'sad_key')
        recipe_mapper = RecipeBuddy::Yummly::RecipeMapper.new(sad_config)
        recipe_mapper.load_several(ROUTE_RECIPES)
      end.must_raise Errors::BadRequest
    end
  end
end

describe 'Tests YouTube API library' do
  extend Econfig::Shortcut

  Econfig.env = 'development'
  Econfig.root = '.'

  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    YT_TOKEN = app.config.YT_TOKEN
    c.filter_sensitive_data('<YOUTUBE_TOKEN>') { YT_TOKEN }
    c.filter_sensitive_data('<YOUTUBE_TOKEN_ESC>') { CGI.escape(YT_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_YOUTUBE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end
  describe 'Video information' do
    before do
      search_query = "search?q=#{RECIPE_TO_SEARCH}"
      video_mapper = RecipeBuddy::Youtube::VideoMapper.new(app.config)
      @videos = video_mapper.load_several(search_query)
    end

    it 'HAPPY: should get the count' do
      _(@videos.count).must_be :<=, 10
    end

    it 'HAPPY: should check that the video fields are valid' do
      video = @videos[0]
      _(video.origin_id).must_be_instance_of String
      _(video.title).must_be_instance_of String
      _(video.published_at).must_be_instance_of DateTime
      _(video.description).must_be_instance_of String
      _(video.channel_id).must_be_instance_of String
      _(video.channel_title).must_be_instance_of String
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        search_query = "search?q=#{RECIPE_TO_SEARCH}"
        sad_config = OpenStruct.new(YT_TOKEN: 'sad_token')
        video_mapper = RecipeBuddy::Youtube::VideoMapper.new(sad_config)
        video_mapper.load_several(search_query)
      end.must_raise Errors::BadRequest
    end
  end
end
