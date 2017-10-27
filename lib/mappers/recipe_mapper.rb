# frozen_string_literal: false

require_relative 'page_mapper.rb'

module RecipeBuddy
  # Provides access to recipes data
  module Facebook
    # Data Mapper for Facebook recipes
    class RecipeMapper
      def initialize(gateway)
        @gateway = gateway
      end

      def load_several(url)
        recipes = @gateway.recipes_data(url)
        recipes.map do |recipe_data|
          RecipeMapper.build_entity(recipe_data)
        end
      end

      def self.build_entity(recipe_data)
        DataMapper.new(recipe_data, @gateway).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(recipe_data, gateway)
          @recipe_data = recipe_data
          @page_mapper = PageMapper.new(gateway)
        end

        def build_entity
          RecipeBuddy::Entity::Recipe.new(
            id: id, created_time: created_time,
            content: content, full_picture: full_picture,
            reactions_like: reactions_like,
            reactions_love: reactions_love,
            reactions_wow: reactions_wow,
            reactions_haha: reactions_haha,
            reactions_sad: reactions_sad,
            reactions_angry: reactions_angry
          )
        end

        def id
          @recipe_data['id']
        end

        def created_time
          DateTime.parse(@recipe_data['created_time'])
        end

        def content
          @recipe_data['message']
        end

        def full_picture
          @recipe_data['full_picture']
        end

        def reactions_like
          @recipe_data['reactions_like']['summary']['total_count']
        end

        def reactions_love
          @recipe_data['reactions_love']['summary']['total_count']
        end

        def reactions_wow
          @recipe_data['reactions_wow']['summary']['total_count']
        end

        def reactions_haha
          @recipe_data['reactions_haha']['summary']['total_count']
        end

        def reactions_sad
          @recipe_data['reactions_sad']['summary']['total_count']
        end

        def reactions_angry
          @recipe_data['reactions_angry']['summary']['total_count']
        end
      end
    end
  end
end
