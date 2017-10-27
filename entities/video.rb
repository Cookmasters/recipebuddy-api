# frozen_string_literal: false

require 'dry-struct'

module RecipeBuddy
  # Module for Recipe
  module Entity
    # Domain entity object
    class Video < Dry::Struct
      attribute :id, Types::Strict::String
      attribute :title, Types::Strict::String
      attribute :published_at, Types::Strict::DateTime
      attribute :description, Types::Strict::String
      attribute :channel_id, Types::Strict::String
      attribute :channel_title, Types::Strict::String
    end
  end
end
