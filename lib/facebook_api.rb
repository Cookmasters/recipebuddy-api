# frozen_string_literal: false

require 'http'
require_relative 'page.rb'
require_relative 'recipe.rb'


module RecipeBuddy
  # Library for Facebook Web API
  class facebookAPI
    module Errors
      class NotFound < StandardError; end
      class Unauthorized < StandardError; end
    end
    HTTP_ERROR = {
      401 => Errors::Unauthorized,
      404 => Errors::NotFound
    }.freeze

    def initialize(token, cache: {})
      @fb_token = token
      @cache = cache
    end

    def page(name)
      page_req_url = fb_api_path(name)
      page_data = call_fb_url(page_req_url).parse
      Page.new(page_data, self)
    end

    def recipe(recipe_url)
      recipe_data = call_fb_url(recipe_url).parse
      recipe_data.map { |recipe| Recipe.new(recipe) }
    end

    private

    def fb_api_path(path)
      'https://graph.facebook.com/v2.10/' + path
    end

    def call_fb_url(url)
      result = @cache.fetch(url) do
        HTTP.headers('Accept' => 'application/json',
                     'Authorization' => "OAuth #{@fb_token}").get(url)
      end

      successful?(result) ? result : raise_error(result)
    end

    def successful?(result)
      HTTP_ERROR.keys.include?(result.code) ? false : true
    end

    def raise_error(result)
      raise(HTTP_ERROR[result.code])
    end

  end
end
