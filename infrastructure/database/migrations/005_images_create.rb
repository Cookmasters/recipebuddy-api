# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:images) do
      primary_key :id
      foreign_key :recipe_id, :recipes

      Integer :size, unique: false
      String :url, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
