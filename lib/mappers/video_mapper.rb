# frozen_string_literal: false

require_relative 'page_mapper.rb'
require 'date'

module RecipeBuddy
  # Provides access to recipes data
  module Youtube
    # Data Mapper for Youtube recipes videos
    class VideoMapper
      def initialize(gateway)
        @gateway = gateway
      end

      def load_several(url)
        videos = @gateway.videos_data(url)
        videos.map do |video_data|
          VideoMapper.build_entity(video_data)
        end
      end

      def self.build_entity(video_data)
        DataMapper.new(video_data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(video_data)
          @video_data = video_data
        end

        def build_entity
          RecipeBuddy::Entity::Video.new(
            id: id, origin_id: origin_id, title: title,
            published_at: published_at, description: description,
            channel_id: channel_id,
            channel_title: channel_title
          )
        end

        def id
          @video_data['snippet']['id']
        end
        def origin_id
          @video_data['id']['videoId']
        end

        def title
          @video_data['snippet']['title']
        end

        def published_at
          DateTime.parse(@video_data['snippet']['publishedAt'])
        end

        def description
          @video_data['snippet']['description']
        end

        def channel_id
          @video_data['snippet']['channelId']
        end

        def channel_title
          @video_data['snippet']['channelTitle']
        end
      end
    end
  end
end
