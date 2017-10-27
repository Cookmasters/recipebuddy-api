# frozen_string_literal: false

require_relative 'spec_helper.rb'
require 'econfig'

describe 'Tests Facebook API library' do
  extend Econfig::Shortcut

  Econfig.env = 'development'
  Econfig.root = '.'

  FB_TOKEN = config.fb_token

  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    fb_token = app.config.fb_token
    c.filter_sensitive_data('<FACEBOOK_TOKEN>') { fb_token }
    c.filter_sensitive_data('<FACEBOOK_TOKEN_ESC>') { CGI.escape(fb_token) }
  end

  before do
    VCR.insert_cassette CASSETTE_FACEBOOK_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Page information' do
    it 'HAPPY: should provide correct page attributes' do
      api = RecipeBuddy::Facebook::Api.new(FB_TOKEN)
      page_mapper = RecipeBuddy::Facebook::PageMapper.new(api)
      page = page_mapper.load(PAGE_NAME)
      _(page.id).must_equal CORRECT_FACEBOOK['id']
      _(page.name).must_equal CORRECT_FACEBOOK['name']
    end

    it 'SAD: should raise exception on incorrect page' do
      proc do
        api = RecipeBuddy::Facebook::Api.new(FB_TOKEN)
        page_mapper = RecipeBuddy::Facebook::PageMapper.new(api)
        page_mapper.load(BAD_PAGE_NAME)
      end.must_raise Errors::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        api = RecipeBuddy::Facebook::Api.new(BAD_FB_TOKEN)
        page_mapper = RecipeBuddy::Facebook::PageMapper.new(api)
        page_mapper.load(PAGE_NAME)
      end.must_raise Errors::Unauthorized
    end
  end

  describe 'Recipe information' do
    before do
      api = RecipeBuddy::Facebook::Api.new(FB_TOKEN)
      page_mapper = RecipeBuddy::Facebook::PageMapper.new(api)
      @page = page_mapper.load(PAGE_NAME)
    end

    it 'HAPPY: should recognize the from page' do
      recipe = @page.recipes[0]
      _(recipe.id.split('_')[0]).must_equal @page.id
    end

    it 'HAPPY: should check that the recipe fields are valid' do
      recipe = @page.recipes[0]
      _(recipe.created_time).must_be_instance_of DateTime
      _(recipe.content).must_be_instance_of String
      _(recipe.id).must_be_instance_of String
      _(recipe.id.split('_')[0]).must_equal @page.id
      _(recipe.reactions_like).must_be :>=, 0
      _(recipe.reactions_love).must_be :>=, 0
      _(recipe.reactions_wow).must_be :>=, 0
      _(recipe.reactions_haha).must_be :>=, 0
      _(recipe.reactions_angry).must_be :>=, 0
      _(recipe.reactions_sad).must_be :>=, 0
      _(recipe.full_picture).must_match %r{https?:\/\/[\S]+}
    end

    # it 'HAPPY: should identify owner page' do
    #   recipe = @page.recipes[0]
    #   _(recipe.from.id).wont_be_nil
    #   _(recipe.from.name).must_equal CORRECT['name']
    # end

    it 'HAPPY: should check recipes' do
      recipes = @page.recipes
      _(recipes.count).must_equal CORRECT_FACEBOOK['posts'].count
    end
  end
end

describe 'Tests YouTube API library' do
  extend Econfig::Shortcut

  Econfig.env = 'development'
  Econfig.root = '.'

  YT_TOKEN = config.yt_token

  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    yt_token = config.yt_token
    c.filter_sensitive_data('<YOUTUBE_TOKEN>') { yt_token }
    c.filter_sensitive_data('<YOUTUBE_TOKEN_ESC>') { CGI.escape(yt_token) }
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
      api = RecipeBuddy::Youtube::Api.new(YT_TOKEN)
      video_mapper = RecipeBuddy::Youtube::VideoMapper.new(api)
      @videos = video_mapper.load_several(search_query)
    end

    it 'HAPPY: should get the count' do
      _(@videos.count).must_equal 5
    end

    it 'HAPPY: should check that the video fields are valid' do
      video = @videos[0]
      _(video.id).must_be_instance_of String
      _(video.title).must_be_instance_of String
      _(video.published_at).must_be_instance_of DateTime
      _(video.description).must_be_instance_of String
      _(video.channel_id).must_be_instance_of String
      _(video.channel_title).must_be_instance_of String
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        search_query = "search?q=#{RECIPE_TO_SEARCH}"
        api = RecipeBuddy::Youtube::Api.new(BAD_FB_TOKEN)
        video_mapper = RecipeBuddy::Youtube::VideoMapper.new(api)
        video_mapper.load_several(search_query)
      end.must_raise Errors::BadRequest
    end
  end
end
