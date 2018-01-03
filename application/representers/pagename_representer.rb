# frozen_string_literal: true

require_relative 'recipe_representer'

# Add Representer to module
module RecipeBuddy
  # Represents essential Page information for API output
  # USAGE:
  #   page = Repository::Pages.find_id(1)
  #   PageRepresenter.new(page).to_json
  class PageNameRepresenter < Roar::Decorator
    include Roar::JSON

    property :id
    property :origin_id
    property :name
  end
end
