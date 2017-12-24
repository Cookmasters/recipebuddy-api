# frozen_string_literal: true

require 'sequel'

module RecipeBuddy
  module Repository
    # Repository for Recipes
    class Recipes
      def self.all
        Database::RecipeOrm.all.map { |db_recipe| rebuild_entity(db_recipe) }
      end

      def self.best
        best_recipes = Database::RecipeOrm.order(Sequel.desc(:reactions_like),
                                                 Sequel.desc(:reactions_love),
                                                 Sequel.desc(:reactions_wow),
                                                 Sequel.desc(:reactions_haha),
                                                 Sequel.asc(:reactions_angry),
                                                 Sequel.asc(:reactions_sad))
                                          .limit(50)
        best_recipes.map { |db_recipe| rebuild_entity(db_recipe) }
      end

      def self.find_id(id)
        db_record = Database::RecipeOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::RecipeOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity, page_id = nil)
        find_origin_id(entity.origin_id) || create(entity, page_id)
      end

      def self.add_stored_id(entity_data, db)
        entity_data.videos.each do |video|
          stored_video = Videos.find_or_create(video)
          video = Database::VideoOrm.first(id: stored_video.id)
          db.add_video(video)
        end

        rebuild_entity(db)
      end

      def self.create(entity, page_id = nil)
        db_recipe = create_helper(entity, page_id)
        add_stored_id(entity, db_recipe)
      end

      # rubocop:disable MethodLength
      # rubocop:disable Metrics/AbcSize
      def self.create_helper(entity, page_id)
        Database::RecipeOrm.create(
          origin_id: entity.origin_id, title: entity.title,
          created_time: entity.created_time,
          content: entity.content, full_picture: entity.full_picture,
          reactions_like: entity.reactions_like,
          reactions_love: entity.reactions_love,
          reactions_wow: entity.reactions_wow,
          reactions_haha: entity.reactions_haha,
          reactions_sad: entity.reactions_sad,
          reactions_angry: entity.reactions_angry,
          page_id: page_id
        )
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        videos = db_record.videos.map do |db_video|
          Videos.rebuild_entity(db_video)
        end

        Entity::Recipe.new(
          id: db_record.id, origin_id: db_record.origin_id,
          title: db_record.title,
          created_time: db_record.created_time.to_datetime,
          content: db_record.content,
          full_picture: db_record.full_picture,
          reactions_like: db_record.reactions_like,
          reactions_love: db_record.reactions_love,
          reactions_wow: db_record.reactions_wow,
          reactions_haha: db_record.reactions_haha,
          reactions_sad: db_record.reactions_sad,
          reactions_angry: db_record.reactions_angry,
          videos: videos
        )
      end
    end
  end
end
