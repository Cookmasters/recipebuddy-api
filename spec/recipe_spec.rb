# frozen_string_literal: false

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/facebook_api.rb'

describe 'Tests Facebook API library' do
  PAGE_NAME = 'RecipesAndCookingGuide'.freeze
  BAD_PAGE_NAME = 'olcooker'.freeze
  CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
  FB_TOKEN = CONFIG['fb_token']
  BAD_FB_TOKEN = 'hastalavista'.freeze
  CORRECT = YAML.safe_load(File.read('spec/fixtures/fb_results.yml'))
  RESPONSE = YAML.load(File.read('spec/fixtures/fb_response.yml'))

  describe 'Page information' do
    it 'HAPPY: should provide correct page attributes' do
      page = RecipeBuddy::FacebookAPI.new(FB_TOKEN, cache: RESPONSE)
                                     .page(PAGE_NAME)
      _(page.id).must_equal CORRECT['id']
      _(page.name).must_equal CORRECT['name']
    end

    it 'SAD: should raise exception on incorrect page' do
      proc do
        RecipeBuddy::FacebookAPI.new(FB_TOKEN, cache: RESPONSE)
                                .page(BAD_PAGE_NAME)
      end.must_raise RecipeBuddy::FacebookAPI::Errors::NotFound
    end

    # it 'SAD: should raise exception when unauthorized' do
    #   proc do
    #     puts RecipeBuddy::FacebookAPI.new(BAD_FB_TOKEN, cache: RESPONSE)
    #                             .page(PAGE_NAME)
    #   end.must_raise RecipeBuddy::FacebookAPI::Errors::Unauthorized
    # end
  end

  describe 'Recipe information' do
    before do
      @page = RecipeBuddy::FacebookAPI.new(FB_TOKEN, cache: RESPONSE)
                                      .page(PAGE_NAME)
    end

    # it 'HAPPY: should recognize owner' do
    #   _(@recipe.owner).must_be_kind_of RecipeBuddy::Contributor
    # end
    #
    # it 'HAPPY: should identify owner' do
    #   _(@recipe.owner.username).wont_be_nil
    #   _(@recipe.owner.username).must_equal CORRECT['owner']['login']
    # end

    it 'HAPPY: should check recipes' do
      recipes = @page.recipes
      _(recipes.count).must_equal CORRECT['posts'].count

      ids = recipes.map(&:id)
      correct_ids = CORRECT['posts'].map { |c| c['id'] }
      _(ids).must_equal correct_ids
    end
  end
end
