# frozen_string_literal: false

require 'http'
require_relative 'page.rb'
require_relative 'recipe.rb'

module RecipeBuddy
  module Errors
    # Not allowed to access resource
    Unauthorized = Class.new(StandardError)
    # Requested resource not found
    NotFound = Class.new(StandardError)
  end
  # Library for Facebook Web API
  class FacebookApi
    # Encapsulates API response success and errors
    class Response
      HTTP_ERROR = {
        401 => Errors::Unauthorized,
        404 => Errors::NotFound
      }.freeze

      def initialize(response)
        @response = response
      end

      def successful?
        HTTP_ERROR.keys.include?(@response.code) ? false : true
      end

      def response_or_error
        successful? ? @response : raise(HTTP_ERROR[@response.code])
      end
    end

    def initialize(token)
      @fb_token = token
    end

    def page(name)
      page_req_url = FacebookApi.path(name)
      page_data = call_fb_url(page_req_url).parse
      Page.new(page_data, self)
    end

    def recipes(path)
      recipes_url = FacebookApi.path(path)
      receipes_response_parsed = call_fb_url(recipes_url).parse
      recipes_data = receipes_response_parsed['data']
      recipes_data.map { |recipe_data| Recipe.new(recipe_data, self) }
    end

    def self.path(path)
      'https://graph.facebook.com/v2.10/' + path
    end

    private

    def call_fb_url(url)
      response = HTTP.headers('Accept' => 'application/json',
                              'Authorization' => "OAuth #{@fb_token}")
                     .get(url)
      Response.new(response).response_or_error
    end
  end
end
