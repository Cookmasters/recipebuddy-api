# frozen_string_literal: false

require_relative 'page.rb'

module RecipeBuddy
  # Model for Recipe
  class Recipe
    def initialize(recipe_data, data_source)
      @recipe = recipe_data
      @data_source = data_source
    end

    def created_time
      @recipe['created_time']
    end

    def content
      @recipe['content']
    end

    def id
      @recipe['id']
    end

    def from
      @from ||= @data_source.page(@recipe['id'].split('_')[0])
    end
  end
end
