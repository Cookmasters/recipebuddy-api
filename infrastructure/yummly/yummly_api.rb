# frozen_string_literal: false

require 'http'
require_relative '../errors.rb'

module RecipeBuddy
  module Yummly
    # Gateway to talk to Yummly API
    class Api
      # Encapsulates API response success and errors
      class Response
        HTTP_ERROR = {
          400 => Errors::BadRequest,
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

      def initialize(app_id, app_key)
        @yummly_id = app_id
        @yummly_key = app_key
      end

      def page_data(name)
        page_req_url = Api.path(name)
        call_yummly_url(page_req_url).parse
      end

      def recipes_data(path)
        recipes_url = Api.path(path)
        call_yummly_url(recipes_url).parse
      end

      def self.path(path)
        'https://api.yummly.com/v1/api/' + path
      end

      private

      def headers
        { 'Accept' => 'application/json',
          'X-Yummly-App-ID' => @yummly_id,
          'X-Yummly-App-Key' => @yummly_key }
      end

      def call_yummly_url(url)
        response = HTTP.headers(headers)
                       .get(url)
        Response.new(response).response_or_error
      end
    end
  end
end
