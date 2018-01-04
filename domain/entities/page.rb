# frozen_string_literal: false

require_relative 'recipe.rb'

module RecipeBuddy
  # Provides access to page data
  module Entity
    # Domain entity object
    class Page < Dry::Struct
      include Dry::Struct::Setters
      attribute :id, Types::Int.optional
      attribute :origin_id, Types::Strict::String
      attribute :name, Types::Strict::String
      attribute :next, Types::String.optional
      attribute :recipes, Types::Array.member(Recipe)
      attribute :request_id, Types::String.optional
    end
  end
end
