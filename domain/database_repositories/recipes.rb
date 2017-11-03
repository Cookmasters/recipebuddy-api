# frozen_string_literal: true

module RecipeBuddy
  module Repository
    # Repository for Recipes
    class Recipes
      def self.find_id(id)
        db_record = Database::RecipeOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::RecipeOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_origin_id(entity.origin_id) || create_from(entity)
      end

      # rubocop:disable MethodLength
      # rubocop:disable Metrics/AbcSize
      def self.create_from(entity)
        db_recipe = Database::RecipeOrm.create(
          origin_id: entity.origin_id, created_time: entity.created_time,
          content: entity.content, full_picture: entity.full_picture,
          reactions_like: entity.reactions_like,
          reactions_love: entity.reactions_love,
          reactions_wow: entity.reactions_wow,
          reactions_haha: entity.reactions_haha,
          reactions_sad: entity.reactions_sad,
          reactions_angry: entity.reactions_angry
        )

        entity.videos.each do |video|
          stored_video = Videos.find_or_create(video)
          video = Database::VideoOrm.first(id: stored_video.id)
          db_recipe.add_video(video)
        end

        rebuild_entity(db_recipe)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        videos = db_record.videos.map do |db_video|
          Videos.rebuild_entity(db_video)
        end

        Entity::Recipe.new(
          id: db_record.id, origin_id: db_record.origin_id,
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