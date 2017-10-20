# frozen_string_literal: false

module RecipeBuddy
  # Provides access to video data
  class Video
    def initialize(video_data, data_source)
      @video = video_data
      @data_source = data_source
    end

    def id
      @video['id']['videoId']
    end

    def title
      @video['snippet']['title']
    end

    def published_at
      @video['snippet']['publishedAt']
    end

    def description
      @video['snippet']['description']
    end

    def channel_id
      @video['snippet']['channelId']
    end

    def channel_title
      @video['snippet']['channelTitle']
    end
  end
end
