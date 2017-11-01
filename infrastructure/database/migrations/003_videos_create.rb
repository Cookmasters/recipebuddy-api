# frozen_string_literal: false

require 'sequel'

Sequel.migration do
  change do
    create_table(:videos) do
      primary_key :id
      String :origin_id, unique: true
      foreign_key :recipe_id, :recipes

      String :title
      DateTime :published_at
      String :description
      String :channel_id
      String :channel_title

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
