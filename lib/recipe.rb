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

    def full_picture
      @recipe['full_picture']
    end

    def reactions_like
      @recipe['reactions_like']['summary']['total_count']
    end

    def reactions_love
      @recipe['reactions_love']['summary']['total_count']
    end

    def reactions_wow
      @recipe['reactions_wow']['summary']['total_count']
    end

    def reactions_haha
      @recipe['reactions_haha']['summary']['total_count']
    end

    def reactions_sad
      @recipe['reactions_sad']['summary']['total_count']
    end

    def reactions_angry
      @recipe['reactions_angry']['summary']['total_count']
    end

    def from
      @from ||= @data_source.page(@recipe['id'].split('_')[0])
    end
  end
end
