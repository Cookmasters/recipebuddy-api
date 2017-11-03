# frozen_string_literal: true

module RecipeBuddy
  module Repository
    # Repository for Page Entities
    class Pages
      def self.find_name(pagename)
        # SELECT * FROM `pages`
        # WHERE (`name` = 'pagename')
        db_page = Database::PageOrm.first(name: pagename)
        rebuild_entity(db_page)
      end

      def self.find_id(id)
        Database::PageOrm.first(id: id)&.rebuild_entity
      end

      def self.find_origin_id(origin_id)
        db_record = Database::PageOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_origin_id(entity.origin_id) || create_from(entity)
      end

      def self.create_from(entity)
        db_page = Database::PageOrm.create(
          origin_id: entity.origin_id,
          name: entity.name
        )
        entity.recipes.each do |recipe|
          stored_recipe = Recipes.find_or_create(recipe)
          recipe = Database::RecipeOrm.first(id: stored_recipe.id)
          db_page.add_recipe(recipe)
        end

        rebuild_entity(db_page)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        recipes = db_record.recipes.map do |db_recipe|
          Recipes.rebuild_entity(db_recipe)
        end

        Entity::Page.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          name: db_record.name,
          recipes: recipes
        )
      end
    end
  end
end
