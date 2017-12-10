# frozen_string_literal: true

require_relative 'recipe_representer'

# Add Representer to module
module RecipeBuddy
  # Represents essential Page information for API output
  # USAGE:
  #   page = Repository::Pages.find_id(1)
  #   PageRepresenter.new(page).to_json
  class PageRepresenter < Roar::Decorator
    include Roar::JSON

    property :origin_id
    property :name
    property :next
    collection :recipes, extend: RecipeRepresenter, class: OpenStruct
  end
end
