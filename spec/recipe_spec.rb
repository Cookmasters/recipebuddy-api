# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests Facebook API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GITHUB_TOKEN>') { FB_TOKEN }
    c.filter_sensitive_data('<GITHUB_TOKEN_ESC>') { CGI.escape(FB_TOKEN) }
  end

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
      page = RecipeBuddy::FacebookApi.new(FB_TOKEN)
                                     .page(PAGE_NAME)
      _(page.id).must_equal CORRECT['id']
      _(page.name).must_equal CORRECT['name']
    end

    it 'SAD: should raise exception on incorrect page' do
      proc do
        RecipeBuddy::FacebookApi.new(FB_TOKEN)
                                .page(BAD_PAGE_NAME)
      end.must_raise RecipeBuddy::Errors::NotFound
    end

    # it 'SAD: should raise exception when unauthorized' do
    #   proc do
    #     puts RecipeBuddy::FacebookApi.new(BAD_FB_TOKEN, cache: RESPONSE)
    #                             .page(PAGE_NAME)
    #   end.must_raise RecipeBuddy::FacebookApi::Errors::Unauthorized
    # end
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

    # it 'HAPPY: should identify owner' do
    #   recipe = @page.recipes[0]
    #   _(recipe.from.id).wont_be_nil
    #   _(recipe.from.name).must_equal CORRECT['name']
    # end
    #
    # it 'HAPPY: should check recipes' do
    #   recipes = @page.recipes
    #   _(recipes.count).must_equal CORRECT['posts'].count
    #
    #   # ids = recipes.map(&:id)
    #   # correct_ids = CORRECT['posts'].map { |c| c['id'] }
    #   # _(ids).must_equal correct_ids
    # end
  end
end
