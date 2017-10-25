# frozen_string_literal: false

module RecipeBuddy
  # Provides access to page data
  module Entity
    # Domain entity object
    class Page
      attr_accessor :id, :name, :recipes_url
      def initialize(id: nil, name: nil, recipes_url: nil)
        @id = id
        @name = name
        @recipes_url = recipes_url
      end
    end
  end
end
