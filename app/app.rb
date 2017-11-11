# frozen_string_literal: true

require 'roda'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :halt

    route do |routing|
      app = Api

      # GET / request
      routing.root do
        { 'message' => "Recipe API v0.1 up in #{app.environment} mode" }
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          # /api/v0.1/page branch
          routing.on 'page', String do |pagename|
            # GET /api/v0.1/page/:pagename request
            routing.get do
              find_result = FindDatabasePage.new.call(pagename: pagename)

              http_response = HttpResponseRepresenter.new(find_result.value)
              response.status = http_response.http_code
              if find_result.success?
                PageRepresenter.new(find_result.value.message).to_json
              else
                http_response.to_json
              end
            end

            # POST '/api/v0.1/page/:pagename request
            routing.post do
              service_result = LoadFromFacebook.new.call(
                config: app.config,
                pagename: pagename
              )

              http_response = HttpResponseRepresenter.new(service_result.value)
              response.status = http_response.http_code
              if service_result.success?
                response['Location'] = "/api/v0.1/page/#{pagename}"
                PageRepresenter.new(service_result.value.message).to_json
              else
                http_response.to_json
              end
            end
          end
        end
      end
    end
  end
end
