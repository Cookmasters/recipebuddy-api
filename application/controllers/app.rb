# frozen_string_literal: true

require 'roda'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :all_verbs
    plugin :multi_route

    require_relative 'recipe'
    require_relative 'page'

    def represent_response(result, representer_class)
      http_response = HttpResponseRepresenter.new(result.value)
      response.status = http_response.http_code
      if result.success?
        yield if block_given?
        representer_class.new(result.value.message).to_json
      else
        http_response.to_json
      end
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET / request
      routing.root do
        message = "Recipe API v0.1 up in #{Api.environment} mode"
        HttpResponseRepresenter.new(Result.new(:ok, message)).to_json
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          @api_root = '/api/v0.1'
          routing.multi_route
        end
      end
    end
  end
end
