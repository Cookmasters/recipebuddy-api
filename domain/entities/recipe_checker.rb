# frozen_string_literal: true

module RecipeBuddy
  module Entity
    # Checks if a single Facebook post is a recipe
    class RecipeChecker
      def initialize(post)
        @post = post
      end

      def recipe?
        content = @post.content
        return false unless content
        count_is_recipe = 0
        content.each_line do |line|
          count_is_recipe = 0 unless numeric?(line[0])
          count_is_recipe += 1 if numeric?(line[0])
          break if count_is_recipe >= 3
        end
        count_is_recipe >= 3
      end

      def numeric?(str)
        Integer(str)
        true
      rescue StandardError
        false
      end
    end
  end
end
