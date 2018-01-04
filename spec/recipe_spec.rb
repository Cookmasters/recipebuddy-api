# frozen_string_literal: false

require_relative 'spec_helper.rb'
require 'econfig'

describe 'Tests Facebook API library' do
  extend Econfig::Shortcut

  Econfig.env = 'development'
  Econfig.root = '.'

  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
    c.ignore_hosts 'sqs.us-east-1.amazonaws.com'

    FB_TOKEN = app.config.FB_TOKEN
    c.filter_sensitive_data('<FACEBOOK_TOKEN>') { FB_TOKEN }
    c.filter_sensitive_data('<FACEBOOK_TOKEN_ESC>') { CGI.escape(FB_TOKEN) }
  end

  # To flush dots and output during testing
  STDOUT.sync

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
      page_mapper = RecipeBuddy::Facebook::PageMapper.new(app.config)
      page = page_mapper.find(PAGE_NAME)
      _(page.origin_id).must_equal CORRECT_FACEBOOK['id']
      # _(page.name).must_equal CORRECT_FACEBOOK['name']
    end

    it 'SAD: should raise exception on incorrect page' do
      proc do
        page_mapper = RecipeBuddy::Facebook::PageMapper.new(app.config)
        page_mapper.find(BAD_PAGE_NAME)
      end.must_raise Errors::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        require 'ostruct'
        sad_config = OpenStruct.new(FB_TOKEN: 'sad_token')
        page_mapper = RecipeBuddy::Facebook::PageMapper.new(sad_config)
        page_mapper.find(PAGE_NAME)
      end.must_raise Errors::Unauthorized
    end
  end

  describe 'Recipe information' do
    before do
      page_mapper = RecipeBuddy::Facebook::PageMapper.new(app.config)
      @page = page_mapper.find(PAGE_NAME)
    end

    it 'HAPPY: should recognize the from page' do
      recipe = @page.recipes[0]
      _(recipe.origin_id.split('_')[0]).must_equal @page.origin_id
    end

    it 'HAPPY: should check that the recipe fields are valid' do
      recipe = @page.recipes[0]
      _(recipe.created_time).must_be_instance_of DateTime
      _(recipe.content).must_be_instance_of String
      _(recipe.origin_id).must_be_instance_of String
      _(recipe.origin_id.split('_')[0]).must_equal @page.origin_id
      _(recipe.reactions_like).must_be :>=, 0
      _(recipe.reactions_love).must_be :>=, 0
      _(recipe.reactions_wow).must_be :>=, 0
      _(recipe.reactions_haha).must_be :>=, 0
      _(recipe.reactions_angry).must_be :>=, 0
      _(recipe.reactions_sad).must_be :>=, 0
      _(recipe.full_picture).must_match %r{https?:\/\/[\S]+}
    end

    it 'HAPPY: should check recipes' do
      recipes = @page.recipes
      _(recipes.count).must_be :<=, 25
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
    c.ignore_hosts 'sqs.us-east-1.amazonaws.com'

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
      _(@videos.count).must_be :<=, 5
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
