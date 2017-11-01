# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Recipe Entities
    class RecipeOrm < Sequel::Model(:recipes)
      many_to_one :recipe,
                  class: :'RecipeBuddy::Database::PageOrm'

      one_to_many :recipe_video,
                  class: :'RecipeBuddy::Database::VideoOrm',
                  key: :origin_id

      plugin :timestamps, update_on_create: true
    end
  end
end
