# frozen_string_literal: true

require_relative 'page_representer'

# Add Representer to module
module RecipeBuddy
  # Represents essential Page information for API output
  # USAGE:
  #   page = Repository::Pages.find_id(1)
  #   PageRepresenter.new(page).to_json
  class PagesRepresenter < Roar::Decorator
    include Roar::JSON

    collection :pages, extend: PageRepresenter, class: OpenStruct
  end
end
