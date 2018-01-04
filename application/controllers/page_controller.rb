# frozen_string_literal: true

require 'roda'
require 'json'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :all_verbs

    # #{API_ROOT}/page branch
    route('page') do |routing|
      # GET #{API_ROOT}/page/all request
      routing.on 'all' do
        routing.get do
          pages = Repository::For[Entity::Page].all
          PagesRepresenter.new(Pages.new(pages)).to_json
        end
      end

      routing.on String do |pagename|
        # GET #{API_ROOT}/page/:pagename request
        routing.get do
          find_result = FindDatabasePage.call(pagename: pagename)
          represent_response(find_result, PageRepresenter)
        end

        # GET #{API_ROOT}/page/:pagename request
        routing.put do
          request_id = [request.env, request.path, Time.now.to_f].hash
          load_result = UpdateFromFacebook.new.call(
            config: Api.config,
            pagename: pagename,
            id: request_id
          )
          represent_response(load_result, PageRepresenter)
        end

        # POST #{API_ROOT}/page/:pagename request
        routing.post do
          request_id = [request.env, request.path, Time.now.to_f].hash
          load_result = LoadFromFacebook.new.call(
            config: Api.config,
            pagename: pagename,
            id: request_id
          )
          represent_response(load_result, PageRepresenter) do
            response['Location'] = "#{@api_root}/page/#{pagename}"
          end
        end
      end
    end
  end
end
