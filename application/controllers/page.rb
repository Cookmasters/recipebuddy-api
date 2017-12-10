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
          represent_response(find_result, PageRepresenter)
        end

        # POST #{API_ROOT}/page/:pagename request
        routing.post do
          load_result = LoadFromFacebook.new.call(
            config: Api.config,
            pagename: pagename
          )

          represent_response(load_result, PageRepresenter) do
            response['Location'] = "#{@api_root}/page/#{pagename}"
          end
        end
      end
    end
  end
end
