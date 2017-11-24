# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Ingredient Entities
    class IngredientOrm < Sequel::Model(:ingredients)
      many_to_many :recipes,
                   class: :'RecipeBuddy::Database::RecipeOrm',
                   join_table: :recipes_ingredients,
                   left_key: :ingredient_id, right_key: :recipe_id

      plugin :timestamps, update_on_create: true
    end
  end
end
