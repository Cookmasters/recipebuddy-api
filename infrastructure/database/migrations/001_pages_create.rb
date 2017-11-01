# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:pages) do
      primary_key :id
      String :origin_id, unique: true
      String :name, unique: false
    end
  end
end
