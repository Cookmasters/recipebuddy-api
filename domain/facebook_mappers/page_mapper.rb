# frozen_string_literal: false

module RecipeBuddy
  # Access for FB module to add Mapper
  module Facebook
    # Data Mapper Object for FB pages
    class PageMapper
      def initialize(config, gateway_class = Facebook::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.FB_TOKEN)
      end

      def find(page_url)
        data = @gateway.page_data(page_url)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @config, @gateway_class).build_entity
      end
    end

    # Extracts entity specific elements from data structure
    class DataMapper
      def initialize(data, config, gateway_class)
        @data = data
        @recipe_mapper = RecipeMapper.new(
          config, gateway_class
        )
        @query = RecipeBuddy::Facebook::Api::Query.new(origin_id)
      end

      def build_entity
        RecipeBuddy::Entity::Page.new(
          id: nil,
          origin_id: origin_id,
          name: name,
          next: recipes[1],
          recipes: recipes[0],
          request_id: nil
        )
      end

      def origin_id
        @data['id']
      end

      def name
        @data['name'].delete(' ')
      end

      def recipes
        @recipe_mapper.load_several(@query.recipes_with_limit_url)
      end
    end
  end
end
