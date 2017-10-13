# frozen_string_literal: false

module RecipeBuddy
  # Provides access to page data
  class Page
    def initialize(page_data)
      @page = page_data
    end

    def id
      @page['id']
    end

    def name
      @page['name']
    end
  end
end
