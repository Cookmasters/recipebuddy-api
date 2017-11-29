# frozen_string_literal: true

require 'roda'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :all_verbs

    # #{API_ROOT}/page branch
    route('page') do |routing|
      routing.on String do |pagename|
        # GET #{API_ROOT}/page/:pagename request
        routing.get do
          find_result = FindDatabasePage.call(pagename: pagename)

          http_response = HttpResponseRepresenter.new(find_result.value)
          response.status = http_response.http_code
          if find_result.success?
            PageRepresenter.new(find_result.value.message).to_json
          else
            http_response.to_json
          end
        end

        # POST #{API_ROOT}/page/:pagename request
        routing.post do
          service_result = LoadFromFacebook.new.call(config: Api.config,
                                                     pagename: pagename)

          http_response = HttpResponseRepresenter.new(service_result.value)
          response.status = http_response.http_code
          if service_result.success?
            response['Location'] = "#{@api_root}/page/#{pagename}"
            PageRepresenter.new(service_result.value.message).to_json
          else
            http_response.to_json
          end
        end
      end
    end
  end
end
