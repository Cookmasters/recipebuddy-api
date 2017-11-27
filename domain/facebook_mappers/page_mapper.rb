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
      end

      def build_entity
        RecipeBuddy::Entity::Page.new(
          id: nil,
          origin_id: origin_id,
          name: name,
          recipes: recipes
        )
      end

      def origin_id
        @data['id']
      end

      def name
        @data['name'].delete(' ')
      end

      def recipes
        recipes_url = recipes_base_url + \
                      recipes_reactions_positive_url + \
                      recipes_reactions_negative_url
        @recipe_mapper.load_several(recipes_url)
      end

      def recipes_base_url
        @data['id'] + '/posts?fields=full_picture,created_time,message'
      end

      def recipes_reactions_positive_url
        ',reactions.type(LIKE).limit(0).summary(total_count)'\
        '.as(reactions_like)'\
        ',reactions.type(LOVE).limit(0).summary(total_count)'\
        '.as(reactions_love)'\
        ',reactions.type(WOW).limit(0).summary(total_count)'\
        '.as(reactions_wow)'\
        ',reactions.type(HAHA).limit(0).summary(total_count)'\
        '.as(reactions_haha)'
      end

      def recipes_reactions_negative_url
        ',reactions.type(SAD).limit(0).summary(total_count)'\
        '.as(reactions_sad)'\
        ',reactions.type(ANGRY).limit(0).summary(total_count)'\
        '.as(reactions_angry)'
      end
    end
  end
end
