# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:pages) do
      primary_key :id, unique: true
      String :name, unique: false
      foreign_key :recipes, :recipes
    end
  end
end
