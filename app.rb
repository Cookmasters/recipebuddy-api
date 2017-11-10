# frozen_string_literal: true

require 'roda'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :halt

    route do |routing|
      # GET / request
      routing.root do
        { 'message' => "Recipe API v0.1 up in #{Api.environment} mode" }
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          # /api/v0.1/page branch
          routing.on 'page', String do |pagename|
            # GET /api/v0.1/page/:pagename request
            routing.get do
              begin
                page = Repository::For[Entity::Page].find_name(pagename)
              rescue StandardError
                error = { error: 'Facebook page not found' }
                routing.halt(500, error.to_json)
              end

              error = { error: 'Facebook page not found' }
              routing.halt(404, error.to_json) unless page
              page.to_h.to_json
            end

            # POST '/api/v0.1/page/:pagename request
            routing.post do
              begin
                page = Facebook::PageMapper.new(app.config).load(pagename)
              rescue StandardError
                error = { error: 'Facebook page not found' }
                routing.halt(404, error.to_json)
              end

              if Repository::For[page.class].find(page)
                error = { error: 'Facebook page not found' }
                routing.halt(409, error.to_json)
              end

              begin
                stored_page = Repository::For[page.class].create(page)
              rescue StandardError
                error = { error: 'Facebook page not found' }
                routing.halt(500, error.to_json)
              end

              response.status = 201
              response['Location'] = "/api/v0.1/page/#{pagename}"
              stored_page.to_h.to_json
            end
          end
        end
      end
    end
  end
end
