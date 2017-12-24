# frozen_string_literal: true

require 'concurrent'
require 'uri'

module RecipeBuddy
  module Entity
    # Checks if a single Facebook page contains recipes
    class PageValidator
      def initialize(page)
        @page = page
      end

      def recipes_page?
        posts_count = @page.recipes.count
        @page.recipes.delete_if do |post|
          true unless RecipeChecker.new(post).recipe?
        end
        ((@page.recipes.count * 1.0) / posts_count) <= 0.5
      end

      def load_videos(config)
        @page.recipes.map do |recipe|
          Concurrent::Promise.execute do
            recipe.videos = recipe_video_loader(recipe, config)
          end
        end.map(&:value)
        @page
      end

      def recipe_video_loader(recipe, config)
        recipe_title = URI.encode_www_form([['q', recipe.title]])
        videos_url = "search?#{recipe_title}"
        Youtube::VideoMapper.new(config).load_several(videos_url)
      end
    end
  end
end
