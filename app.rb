# frozen_string_literal: true

require 'roda'
require 'econfig'
require_relative 'lib/init.rb'
require_relative 'config/environment.rb'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :json
    plugin :halt
    plugin :multi_route

    route do |routing|
      app = Api
      config = Api.config

      # GET / request
      routing.root do
        { 'message' => "Recipe API v0.1 up in #{app.environment}" }
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          # /api/v0.1/page branch
          routing.on 'page', String do |pagename|
            facebook_api = Facebook::Api.new(config.fb_token)
            page_mapper = Facebook::PageMapper.new(facebook_api)
            begin
              page = page_mapper.load(pagename)
            rescue StandardError
              routing.halt(404, error: 'Facebook page not found')
            end

            # GET /api/v0.1/page/:pagename request
            routing.is do
              { page: { id: page.id, name: page.name } }
            end

            # GET /api/v0.1/page/:pagename/recipes request
            routing.get 'recipes' do
              { recipes: page.recipes.map(&:to_h) }
            end
          end

          # /api/v0.1/recipe branch
          routing.on 'recipe', String do |recipename|
            youtube_api = Youtube::Api.new(config.yt_token)
            video_mapper = Youtube::VideoMapper.new(youtube_api)
            search_query = "search?q=#{recipename}"
            begin
              videos = video_mapper.load_several(search_query)
            rescue StandardError
              routing.halt(404, error: 'Youtube videos not found')
            end

            # GET /api/v0.1/recipe/:recipename request
            routing.is do
              { videos: videos.map(&:to_h) }
            end
          end
        end
      end
    end
  end
end
