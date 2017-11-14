# frozen_string_literal: false

require 'http'
require 'cgi'

require_relative '../errors.rb'

module RecipeBuddy
  module Youtube
    # Gateway to talk to Youtube API
    class Api
      # Encapsulates API response success and errors
      class Response
        HTTP_ERROR = {
          401 => Errors::Unauthorized,
          404 => Errors::NotFound,
          400 => Errors::BadRequest
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
        @yt_token = token
      end

      def videos_data(path)
        recipe_videos_url = videos_path(path)
        videos_response_parsed = call_yt_url(recipe_videos_url).parse
        videos_response_parsed['items']
      end

      def videos_path(path)
        search_default_param = "key=#{@yt_token}&part=snippet&chart=mostPopular"
        path = if path.include?('?')
                 "#{path}&#{search_default_param}"
               else
                 "?#{path}&#{search_default_param}"
               end
        'https://www.googleapis.com/youtube/v3/' + path
      end

      private

      def headers
        { 'Accept' => 'application/json' }
      end

      def call_yt_url(url)
        response = HTTP.headers(headers)
                       .get(url)
        Response.new(response).response_or_error
      end
    end
  end
end
