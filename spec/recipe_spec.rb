# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests Facebook API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<FACEBOOK_TOKEN>') { FB_TOKEN }
    c.filter_sensitive_data('<FACEBOOK_TOKEN_ESC>') { CGI.escape(FB_TOKEN) }
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
      page = RecipeBuddy::FacebookApi.new(FB_TOKEN)
                                     .page(PAGE_NAME)
      _(page.id).must_equal CORRECT['id']
      _(page.name).must_equal CORRECT['name']
    end

    it 'SAD: should raise exception on incorrect page' do
      proc do
        RecipeBuddy::FacebookApi.new(FB_TOKEN)
                                .page(BAD_PAGE_NAME)
      end.must_raise Errors::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        RecipeBuddy::FacebookApi.new(BAD_FB_TOKEN)
                                .page(PAGE_NAME)
      end.must_raise Errors::Unauthorized
    end
  end

  describe 'Recipe information' do
    before do
      @page = RecipeBuddy::FacebookApi.new(FB_TOKEN)
                                      .page(PAGE_NAME)
    end

    it 'HAPPY: should recognize the from page' do
      recipe = @page.recipes[0]
      _(recipe.from).must_be_kind_of RecipeBuddy::Page
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

    it 'HAPPY: should identify owner' do
      recipe = @page.recipes[0]
      _(recipe.from.id).wont_be_nil
      _(recipe.from.name).must_equal CORRECT['name']
    end

    it 'HAPPY: should check recipes' do
      recipes = @page.recipes
      _(recipes.count).must_equal CORRECT['posts'].count

      # ids = recipes.map(&:id)
      # correct_ids = CORRECT['posts'].map { |c| c['id'] }
      # _(ids).must_equal correct_ids
    end
  end
end

describe 'Tests YouTube API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

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
      @videos = RecipeBuddy::YoutubeApi.new(YT_TOKEN)
                                       .videos(search_query)
      @videos.count
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
        RecipeBuddy::YoutubeApi.new(BAD_FB_TOKEN)
                               .videos(search_query)
      end.must_raise Errors::BadRequest
    end
  end
end
