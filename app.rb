# frozen_string_literal: true

require 'roda'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :json
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
              page = Repository::For[Entity::Page].find_name(pagename)
              routing.halt(404, error: 'Facebook page not found') unless page
              page.to_h
            end

            # POST '/api/v0.1/page/:pagename request
            routing.post do
              begin
                page = Facebook::PageMapper.new(app.config).load(pagename)
              rescue StandardError
                routing.halt(404, error: 'Facebook page not found')
              end
              stored_page = Repository::For[page.class].find_or_create(page)
              response.status = 201
              response['Location'] = "/api/v0.1/page/#{pagename}"
              stored_page.to_h
            end
          end
        end
      end
    end
  end
end
