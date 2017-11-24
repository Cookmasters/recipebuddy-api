# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Recipe Entities
    class RecipeOrm < Sequel::Model(:recipes)
      many_to_many :ingredients,
                   class: :'RecipeBuddy::Database::IngredientOrm',
                   join_table: :recipes_ingredients,
                   left_key: :recipe_id, right_key: :ingredient_id

      one_to_many :videos,
                  class: :'RecipeBuddy::Database::VideoOrm',
                  key: :recipe_id

      plugin :timestamps, update_on_create: true
    end
  end
end
