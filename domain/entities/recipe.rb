# frozen_string_literal: false

require 'dry-struct'

require_relative 'video.rb'
require_relative 'ingredient.rb'
require_relative 'image.rb'

module RecipeBuddy
  # Module for Recipe
  module Entity
    # Domain entity object
    class Recipe < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :origin_id, Types::Strict::String
      attribute :name, Types::Strict::String
      attribute :rating, Types::Strict::Int
      attribute :total_time_in_seconds, Types::Strict::Int
      attribute :number_of_servings, Types::Strict::Int
      attribute :flavors, Types::String.optional
      attribute :categories, Types::Strict::Array.member(String)
      attribute :ingredient_lines, Types::Strict::Array.member(String)
      attribute :likes, Types::Strict::Int.default(0)
      attribute :dislikes, Types::Strict::Int.default(0)
      attribute :videos, Types::Strict::Array.member(Video)
      attribute :ingredients, Types::Strict::Array.member(Ingredient)
      attribute :images, Types::Strict::Array.member(Image)
    end
  end
end
