# frozen_string_literal: false

require_relative 'page_mapper.rb'
module RecipeBuddy
  # Access for FB module to add Mapper
  module Facebook
    # Recipe Mapper Object for FB pages
    class RecipeMapper
      def initialize(data_source)
        @data_source = data_source
      end

      def load(page_id, recipe_id)
        recipe_data = @data_source.recipe_data(page_id, recipe_id)
        build_entity(recipe_data)
      end

      def build_entity(recipe_data)
        mapper = DataMap.new(recipe_data, @data_source)

        RepoPraise::Entity::Repo.new(
          created_time: mapper.created_time,
          content: mapper.content,
          id: mapper.id,
          full_picture: mapper.full_picture,
          reactions_like: mapper.reactions_like,
          reactions_love: mapper.reactions_love,
          reactions_wow: mapper.reactions_wow,
          reactions_haha: mapper.reactions_haha,
          reactions_sad: mapper.reactions_sad,
          reactions_angry: mapper.reactions_angry
        )
      end

      # Extracts entity specific elements from data structure
      class DataMap
        def initialize(recipe_data, data_source)
          @recipe = recipe_data
          @page_mapper = PageMapper.new(data_source)
        end

        def created_time
          DateTime.parse(@recipe['created_time'])
        end

        def content
          @recipe['message']
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

        # def from
        # @from ||= @data_source.page(@recipe['id'].split('_')[0])
        # end
      end
    end
  end
end
