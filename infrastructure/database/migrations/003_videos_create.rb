# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:videos) do
      primary_key :id
      String :title
      DateTime :published_at
      String :description
      String :channel_id, unique: true
      String :channel_title

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
