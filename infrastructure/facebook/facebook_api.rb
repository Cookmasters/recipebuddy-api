# frozen_string_literal: false

require 'http'
require_relative '../errors.rb'

module RecipeBuddy
  module Facebook
    # Gateway to talk to Facebook API
    class Api
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

      def page_data(name)
        page_req_url = Api.path(name)
        call_fb_url(page_req_url).parse
      end

      def recipes_data(path)
        recipes_url = Api.path(path)
        recipes_response_parsed = call_fb_url(recipes_url).parse
        recipes_response_parsed['data']
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
end
