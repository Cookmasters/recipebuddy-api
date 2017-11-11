# frozen_string_literal: true

module RecipeBuddy
  module Repository
    # Repository for Videos
    class Videos
      def self.find_id(id)
        db_record = Database::VideoOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::VideoOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_origin_id(entity.origin_id) || create_from(entity)
      end

      def self.all
        Database::VideoOrm.all.map { |db_video| rebuild_entity(db_video) }
      end

      def self.create_from(entity)
        db_recipe = Database::VideoOrm.create(
          origin_id: entity.origin_id, title: entity.title,
          published_at: entity.published_at, description: entity.description,
          channel_id: entity.channel_id,
          channel_title: entity.channel_title
        )
        rebuild_entity(db_recipe)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Video.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          title: db_record.title,
          published_at: db_record.published_at.to_datetime,
          description: db_record.description,
          channel_id: db_record.channel_id,
          channel_title: db_record.channel_title
        )
      end
    end
  end
end
