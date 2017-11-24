# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:ingredients) do
      primary_key :id
      String :origin_id, unique: true
      String :name, unique: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
