# frozen_string_literal: true

require 'dry/transaction'

module RecipeBuddy
  # Service to find a recipe from database
  # Usage:
  #   result = FindDatabaseRecipe.call(id: 1)
  #   result.success?
  module FindDatabaseRecipe
    extend Dry::Monads::Either::Mixin

    def self.call(input)
      recipe = Repository::For[Entity::Recipe]
               .find_id(input[:id])
      if recipe
        Right(Result.new(:ok, recipe))
      else
        Left(Result.new(:not_found, 'Could not find stored recipe'))
      end
    end
  end
end
