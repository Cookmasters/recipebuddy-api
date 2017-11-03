# frozen_string_literal: false

require_relative 'recipe.rb'

module RecipeBuddy
  # Provides access to page data
  module Entity
    # Domain entity object
    class Page < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :origin_id, Types::Strict::String
      attribute :name, Types::Strict::String
      attribute :recipes, Types::Strict::Array.member(Recipe)
    end
  end
end
