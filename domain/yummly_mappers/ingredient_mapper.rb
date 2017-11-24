# frozen_string_literal: false

module RecipeBuddy
  # Provides access to ingredients data
  module Yummly
    # Data Mapper for Yummly ingredients
    class IngredientMapper
      def initialize(config, gateway_class = Yummly::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.YUMMLY_ID, @config.YUMMLY_KEY)
      end

      def parse_data(data)
        ingredients = data
        ingredients.map do |ingredient|
          build_entity(ingredient)
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
          RecipeBuddy::Entity::Ingredient.new(
            id: nil, name: name
          )
        end

        def name
          @data
        end
      end
    end
  end
end
