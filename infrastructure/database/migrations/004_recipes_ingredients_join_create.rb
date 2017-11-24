# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:recipes_ingredients) do
      foreign_key :recipe_id, :recipes
      foreign_key :ingredient_id, :ingredients
      primary_key %i[recipe_id ingredient_id]
      index %i[recipe_id ingredient_id]
    end
  end
end
