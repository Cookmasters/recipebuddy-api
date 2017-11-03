# frozen_string_literal: true

module RecipeBuddy
  module Repository
    For = {
      Entity::Page         => Pages,
      Entity::Recipe       => Recipes,
      Entity::Video        => Videos
    }.freeze
  end
end
