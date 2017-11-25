# frozen_string_literal: false

# require_relative 'video_mapper.rb'

module RecipeBuddy
  # Provides access to recipes data
  module Facebook
    # Data Mapper for Facebook recipes
    class RecipeMapper
      def initialize(config, gateway_class = Facebook::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.FB_TOKEN)
      end

      def load_several(url)
        recipes = @gateway.recipes_data(url)
        recipes.map do |data|
          build_entity(data)
        end
      end

      def build_entity(data)
        DataMapper.new(data, @config).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, config)
          @data = data
          @video_mapper = RecipeBuddy::Youtube::VideoMapper.new(
            config
          )
        end

        def build_entity
          RecipeBuddy::Entity::Recipe.new(
            id: nil, origin_id: origin_id, title: title,
            created_time: created_time,
            content: content, full_picture: full_picture,
            reactions_like: reactions_like,
            reactions_love: reactions_love,
            reactions_wow: reactions_wow,
            reactions_haha: reactions_haha, reactions_sad: reactions_sad,
            reactions_angry: reactions_angry, videos: videos
          )
        end

        def origin_id
          @data['id']
        end

        def created_time
          DateTime.parse(@data['created_time'])
        end

        def content
          # Remove all the special characters and keep only letters and numbers
          @data['message'].gsub(%r{[^0-9A-Za-z\n\. \/-]}, '')
        end

        def full_picture
          @data['full_picture']
        end

        def reactions_like
          @data['reactions_like']['summary']['total_count']
        end

        def reactions_love
          @data['reactions_love']['summary']['total_count']
        end

        def reactions_wow
          @data['reactions_wow']['summary']['total_count']
        end

        def reactions_haha
          @data['reactions_haha']['summary']['total_count']
        end

        def reactions_sad
          @data['reactions_sad']['summary']['total_count']
        end

        def reactions_angry
          @data['reactions_angry']['summary']['total_count']
        end

        def title
          content.split("\n")[0]
        end

        def videos
          []
        end
      end
    end
  end
end
