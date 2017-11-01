# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Page Entities
    class PageOrm < Sequel::Model(:pages)
      one_to_many :main_page,
                  class: :'RecipeBuddy::Database::RecipeOrm',
                  key: :origin_id

      plugin :timestamps, update_on_create: true
    end
  end
end
