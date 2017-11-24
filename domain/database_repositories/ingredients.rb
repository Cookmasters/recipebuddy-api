# frozen_string_literal: true

module RecipeBuddy
  module Repository
    # Repository for Ingredient Entities
    class Ingredients
      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_name(name)
        # SELECT * FROM `ingredients`
        # WHERE (`name` = 'pagename')
        db_page = Database::IngredientOrm.first(name: pagename)
        rebuild_entity(db_page)
      end

      def self.find_id(id)
        Database::IngredientOrm.first(id: id).try(rebuild_entity)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::IngredientOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.add_stored_id(entity_data, db)
        entity_data.recipes.each do |recipe|
          stored_recipe = Recipes.find_or_create(recipe)
          recipe = Database::RecipeOrm.first(id: stored_recipe.id)
          db.add_recipe(recipe)
        end
        rebuild_entity(db)
      end

      def self.all
        Database::IngredientOrm.all.map { |db_page| rebuild_entity(db_page) }
      end

      def self.create(entity)
        raise 'Facebook page already exists' if find(entity)

        db_page = Database::IngredientOrm.create(
          origin_id: entity.origin_id,
          name: entity.name
        )
        add_stored_id(entity, db_page)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        recipes = db_record.recipes.map do |db_recipe|
          Recipes.rebuild_entity(db_recipe)
        end

        Entity::Ingredient.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          name: db_record.name,
          recipes: recipes
        )
      end
    end
  end
end
