# frozen_string_literal: false

require_relative 'recipe_mapper.rb'

module RecipeBuddy
  # Access for FB module to add Mapper
  module Facebook
    # Data Mapper Object for FB pages
    class PageMapper
      def initialize(gateway)
        @gateway = gateway
      end

      def load(page_name)
        page_data = @gateway.page_data(page_name)
        build_entity(page_data)
      end

      def build_entity(page_data)
        DataMapper.new(page_data, @gateway).build_entity
      end
    end

    # Extracts entity specific elements from data structure
    class DataMapper
      def initialize(page_data, gateway)
        @page_data = page_data
        @recipe_mapper = RecipeMapper.new(gateway)
      end

      def build_entity
        RecipeBuddy::Entity::Page.new(
          id: id,
          origin_id: origin_id,
          name: name,
          recipes: recipes
        )
      end

      private

      def id
        @page_data['id']
      end

      def origin_id
        @page_data['id']
      end

      def name
        @page_data['name']
      end

      def recipes
        recipes_url = recipes_base_url + \
                      recipes_reactions_positive_url + \
                      recipes_reactions_negative_url
        @recipe_mapper.load_several(recipes_url)
      end

      def recipes_base_url
        @page_data['id'] + '/posts?fields=full_picture,created_time,message'
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
