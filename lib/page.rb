# frozen_string_literal: false

module RecipeBuddy
  # Provides access to page data
  class Page
    def initialize(page_data, data_source)
      @page = page_data
      @data_source = data_source
    end

    def id
      @page['id']
    end

    def name
      @page['name']
    end

    def recipes_url
      @page['id'] + '/posts'
    end

    def recipes
      @recipes ||= @data_source.recipes(@page['id'] + '/posts')
    end
  end
end
