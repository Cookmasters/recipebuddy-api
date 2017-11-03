# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Recipe Entities
    class RecipeOrm < Sequel::Model(:recipes)
      many_to_one :from,
                  class: :'RecipeBuddy::Database::PageOrm'

      one_to_many :videos,
                  class: :'RecipeBuddy::Database::VideoOrm',
                  key: :recipe_id

      plugin :timestamps, update_on_create: true
    end
  end
end
