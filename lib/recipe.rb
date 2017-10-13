# frozen_string_literal: false

require_relative 'page.rb'

module RecipeBuddy
  # Model for Recipe
  class Recipe
    def initialize(recipe_data)
      @recipe = recipe_data
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

    # def from
    #   @from ||= Page.new(@repo['owner'])
    # end
  end
end
