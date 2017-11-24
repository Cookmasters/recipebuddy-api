# frozen_string_literal: false

require 'uri'
require_relative 'ingredient_mapper.rb'
require_relative 'image_mapper.rb'
# require_relative 'video_mapper.rb'

module RecipeBuddy
  # Provides access to recipes data
  module Yummly
    # Data Mapper for Yummly recipes
    class RecipeMapper
      def initialize(config, gateway_class = Yummly::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.YUMMLY_ID, @config.YUMMLY_KEY)
      end

      def load_several(url)
        raw_response = @gateway.recipes_data(url)
        recipes = raw_response['matches']
        recipes.map do |data|
          recipe_url = "recipe/#{data['id']}"
          recipe = @gateway.recipes_data(recipe_url)
          build_entity(data, recipe)
        end
      end

      def build_entity(data, recipe)
        DataMapper.new(data, recipe, @config).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, recipe, config)
          @data = data
          @recipe = recipe
          @video_mapper = RecipeBuddy::Youtube::VideoMapper.new(config)
          @ingredient_mapper = RecipeBuddy::Yummly::IngredientMapper.new(
            config
          )
          @image_mapper = RecipeBuddy::Yummly::ImageMapper.new(config)
        end

        def build_entity
          RecipeBuddy::Entity::Recipe.new(
            id: nil, origin_id: origin_id, name: name,
            rating: rating, total_time_in_seconds: total_time_in_seconds,
            number_of_servings: number_of_servings,
            flavors: flavors,
            categories: categories,
            ingredient_lines: ingredient_lines,
            likes: nil, dislikes: nil,
            videos: videos, ingredients: ingredients, images: images
          )
        end

        def origin_id
          @data['id']
        end

        def name
          @data['recipeName']
        end

        def rating
          @data['rating']
        end

        def total_time_in_seconds
          @data['totalTimeInSeconds']
        end

        def number_of_servings
          @recipe['numberOfServings']
        end

        def recipe
          @video_mapper.load_several(videos_url)
        end

        def flavors
          @data['flavors']
        end

        def categories
          @data['attributes']['course']
        end

        def ingredient_lines
          @recipe['ingredientLines']
        end

        def videos
          encoded_name = URI.encode_www_form([['q', name]])
          videos_url = "search?#{encoded_name}"
          @video_mapper.load_several(videos_url)
        end

        def ingredients
          @ingredient_mapper.parse_data(@data['ingredients'])
        end

        def images
          @image_mapper.parse_data(@data['imageUrlsBySize'])
        end
      end
    end
  end
end
