# frozen_string_literal: false

require 'dry-struct'
require_relative 'page.rb'

module RecipeBuddy
  # Module for Recipe
  module Entity
    # Domain entity object
    class Recipe < Dry::Struct
      attribute :id, Types::Strict::String
      attribute :created_time, Types::Strict::DateTime
      attribute :content, Types::Strict::String
      attribute :full_picture, Types::Strict::String
      attribute :reactions_like, Types::Strict::Int
      attribute :reactions_love, Types::Strict::Int
      attribute :reactions_wow, Types::Strict::Int
      attribute :reactions_haha, Types::Strict::Int
      attribute :reactions_sad, Types::Strict::Int
      attribute :reactions_angry, Types::Strict::Int
      # attribute :from, Page
    end
  end
end
