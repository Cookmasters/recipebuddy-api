# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:recipes) do
      primary_key :id
      String :origin_id, unique: true

      String :name
      Integer :rating
      Integer :total_time_in_seconds
      Integer :number_of_servings
      String :flavors
      Array :categories
      Array :ingredient_lines
      Integer :likes
      Integer :dislikes

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
