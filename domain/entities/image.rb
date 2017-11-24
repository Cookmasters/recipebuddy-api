# frozen_string_literal: false

require 'dry-struct'

module RecipeBuddy
  # Provides access to page data
  module Entity
    # Domain entity object
    class Image < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :size, Types::Strict::Int
      attribute :url, Types::Strict::String
    end
  end
end
