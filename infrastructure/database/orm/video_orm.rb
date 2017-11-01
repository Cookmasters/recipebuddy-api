# frozen_string_literal: true

module RecipeBuddy
  module Database
    # Object Relational Mapper for Videos Entities
    class VideoOrm < Sequel::Model(:videos)
      many_to_one :video,
                  class: :'RecipeBuddy::Database::RecipeOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
