# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:recipes) do
      primary_key :id
      String :origin_id, unique: true
      foreign_key :page_id, :pages

      DateTime :created_time
      String :title
      String :content
      String :full_picture
      Integer :reactions_like
      Integer :reactions_love
      Integer :reactions_wow
      Integer :reactions_haha
      Integer :reactions_sad
      Integer :reactions_angry

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
