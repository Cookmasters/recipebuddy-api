# frozen_string_literal: false

# require_relative 'page_mapper.rb'
require 'date'

module RecipeBuddy
  # Provides access to recipes data
  module Youtube
    # Data Mapper for Youtube recipes videos
    class VideoMapper
      def initialize(config, gateway_class = Youtube::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.YT_TOKEN)
      end

      def load_several(url)
        videos = @gateway.videos_data(url)
        videos.map do |data|
          video_url = "videos?part=snippet&id=#{data['id']['videoId']}"
          video = @gateway.video_data(video_url)
          VideoMapper.build_entity(data, video)
        end
      end

      def self.build_entity(data, video)
        DataMapper.new(data, video).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, video)
          @data = data
          @video = video
        end

        def build_entity
          RecipeBuddy::Entity::Video.new(
            id: nil, origin_id: origin_id, title: title,
            published_at: published_at, description: description,
            channel_id: channel_id,
            channel_title: channel_title,
            full_description: full_description
          )
        end

        def origin_id
          @data['id']['videoId']
        end

        def title
          @data['snippet']['title']
        end

        def published_at
          DateTime.parse(@data['snippet']['publishedAt'])
        end

        def description
          @data['snippet']['description']
        end

        def full_description
          @video['items'][0]['snippet']['description']
        end

        def channel_id
          @data['snippet']['channelId']
        end

        def channel_title
          @data['snippet']['channelTitle']
        end
      end
    end
  end
end
