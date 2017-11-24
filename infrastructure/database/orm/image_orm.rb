# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Image Entities
    class ImageOrm < Sequel::Model(:images)
      many_to_one :recipe,
                  class: :'RecipeBuddy::Database::RecipeOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
