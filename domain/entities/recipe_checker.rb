# frozen_string_literal: true

module RecipeBuddy
  module Entity
    # Checks if a single Facebook post is a recipe
    class RecipeChecker
      def initialize(post)
        @post = post
        @title = post.title
      end

      def recipe?
        content = @post.content
        return false unless content
        count_ingredient_lines(content) >= 3
      end

      def count_ingredient_lines(content)
        ingredients_count = 0
        content.each_line.with_index do |line, index|
          next if line == "\n"
          is_ingredient = numeric?(line[0])
          @title = get_title(line, index, @title, is_ingredient)
          ingredients_count = 0 unless is_ingredient
          ingredients_count += 1 if is_ingredient
          break if ingredients_count >= 3
        end
        ingredients_count
      end

      def get_title(line, index, previous_title, is_ingredient)
        return line if index.zero?
        return line if !is_ingredient &&
                       !line.downcase.start_with?('ingredient')
        previous_title
      end

      def recipe_title
        @title
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
