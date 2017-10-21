# frozen_string_literal: false

require 'http'
require_relative 'page.rb'
require_relative 'recipe.rb'
require_relative 'errors.rb'

module RecipeBuddy
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
        return false if HTTP_ERROR.keys.include?(@response.code)
        # return false unless @response['errors'].nil?
        true
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

    def headers
      { 'Accept' => 'application/json',
        'Authorization' => "OAuth #{@fb_token}" }
    end

    def call_fb_url(url)
      response = HTTP.headers(headers)
                     .get(url)
      Response.new(response).response_or_error
    end
  end
end
