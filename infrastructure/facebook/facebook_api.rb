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

      # Contains all the Query details
      class Query
        def initialize(page_id, token = nil)
          @page_id = page_id
          @token = token
        end

        def recipes_base_url
          '/posts?fields=full_picture,created_time,message'
        end

        def recipes_reactions_positive_url
          ',reactions.type(LIKE).limit(0).summary(total_count)'\
          '.as(reactions_like)'\
          ',reactions.type(LOVE).limit(0).summary(total_count)'\
          '.as(reactions_love)'\
          ',reactions.type(WOW).limit(0).summary(total_count)'\
          '.as(reactions_wow)'\
          ',reactions.type(HAHA).limit(0).summary(total_count)'\
          '.as(reactions_haha)'
        end

        def recipes_reactions_negative_url
          ',reactions.type(SAD).limit(0).summary(total_count)'\
          '.as(reactions_sad)'\
          ',reactions.type(ANGRY).limit(0).summary(total_count)'\
          '.as(reactions_angry)'
        end

        def recipes_next_url
          "&limit=100&after=#{@token}"
        end

        def recipes_url
          @page_id + recipes_base_url + recipes_reactions_positive_url + \
            recipes_reactions_negative_url
        end

        def recipes_with_limit_url(limit = 25)
          @page_id + recipes_base_url + recipes_reactions_positive_url + \
            recipes_reactions_negative_url + "&limit=#{limit}"
        end

        def recipes_next_page
          recipes_url + recipes_next_url
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
        call_fb_url(recipes_url).parse
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
