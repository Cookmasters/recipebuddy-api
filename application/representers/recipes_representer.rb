# frozen_string_literal: true

require_relative 'recipe_representer'

# Represents essential Recipe information for API output
module RecipeBuddy
  # Recipe
  class RecipesRepresenter < Roar::Decorator
    include Roar::JSON

    collection :recipes, extend: RecipeRepresenter, class: OpenStruct
  end
end
