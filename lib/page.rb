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
      @page['id'] + '/posts?fields=full_picture,created_time,message'\
      ',reactions.type(LIKE).limit(0).summary(total_count).as(reactions_like)'\
      ',reactions.type(LOVE).limit(0).summary(total_count).as(reactions_love)'\
      ',reactions.type(WOW).limit(0).summary(total_count).as(reactions_wow)'\
      ',reactions.type(HAHA).limit(0).summary(total_count).as(reactions_haha)'\
      ',reactions.type(SAD).limit(0).summary(total_count).as(reactions_sad)'\
      ',reactions.type(ANGRY).limit(0).summary(total_count).as(reactions_angry)'
    end

    def recipes
      @recipes ||= @data_source.recipes(recipes_url)
    end
  end
end
