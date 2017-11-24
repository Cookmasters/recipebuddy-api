# frozen_string_literal: true

module RecipeBuddy
  module Repository
    # Repository for Recipes
    class Recipes
      def self.all
        Database::RecipeOrm.all.map { |db_recipe| rebuild_entity(db_recipe) }
      end

      def self.find_id(id)
        db_record = Database::RecipeOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::RecipeOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_origin_id(entity.origin_id) || create(entity)
      end

      def self.add_stored_id(entity_data, db)
        entity_data.videos.each do |video|
          stored_video = Videos.find_or_create(video)
          video = Database::VideoOrm.first(id: stored_video.id)
          db.add_video(video)
        end

        entity_data.ingredients.each do |ingredient|
          stored_ingredient = Ingredients.find_or_create(ingredient)
          ingredient = Database::IngredientOrm.first(id: stored_ingredient.id)
          db.add_ingredient(ingredient)
        end

        rebuild_entity(db)
      end

      # rubocop:disable MethodLength
      # rubocop:disable Metrics/AbcSize
      def self.create(entity)
        db_recipe = Database::RecipeOrm.create(
          origin_id: entity.origin_id, name: entity.name,
          rating: entity.rating,
          total_time_in_seconds: entity.total_time_in_seconds,
          number_of_servings: entity.number_of_servings,
          flavors: entity.flavors,
          categories: entity.categories,
          ingredient_lines: entity.ingredient_lines,
          likes: entity.likes,
          dislikes: entity.dislikes
        )
        add_stored_id(entity, db_recipe)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        videos = db_record.videos.map do |db_video|
          Videos.rebuild_entity(db_video)
        end

        ingredients = db_record.ingredients.map do |db_ingredient|
          Ingredients.rebuild_entity(db_ingredient)
        end

        images = db_record.images.map do |db_image|
          Images.rebuild_entity(db_image)
        end

        Entity::Recipe.new(
          id: db_record.id, origin_id: db_record.origin_id,
          name: db_record.name,
          rating: db_record.rating,
          total_time_in_seconds: db_record.total_time_in_seconds,
          number_of_servings: db_record.number_of_servings,
          flavors: db_record.flavors,
          categories: db_record.categories,
          ingredient_lines: db_record.ingredient_lines,
          likes: db_record.likes,
          dislikes: db_record.dislikes,
          videos: videos, ingredients: ingredients,
          images: images
        )
      end
    end
  end
end
