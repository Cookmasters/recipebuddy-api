# frozen_string_literal: false

module RecipeBuddy
  # Provides access to images data
  module Yummly
    # Data Mapper for Yummly images
    class ImageMapper
      def initialize(config, gateway_class = Yummly::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.YUMMLY_ID, @config.YUMMLY_KEY)
      end

      def parse_data(data)
        images = data
        images.map do |image|
          build_entity(image)
        end
      end

      def build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          RecipeBuddy::Entity::Image.new(
            id: nil, size: size, url: url
          )
        end

        def size
          @data[0].to_i
        end

        def url
          @data[1]
        end
      end
    end
  end
end
