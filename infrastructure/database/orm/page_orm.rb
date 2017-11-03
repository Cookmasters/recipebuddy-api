# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Page Entities
    class PageOrm < Sequel::Model(:pages)
      one_to_many :recipes,
                  class: :'RecipeBuddy::Database::RecipeOrm',
                  key: :page_id

      plugin :timestamps, update_on_create: true
    end
  end
end
