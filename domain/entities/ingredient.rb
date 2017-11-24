# frozen_string_literal: false

require 'dry-struct'

module RecipeBuddy
  # Provides access to page data
  module Entity
    # Domain entity object
    class Ingredient < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :name, Types::Strict::String
    end
  end
end
