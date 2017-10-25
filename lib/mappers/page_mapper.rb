# frozen_string_literal: false

module RecipeBuddy
  # Access for FB module to add Mapper
  module Facebook
    # Data Mapper Object for FB pages
    class PageMapper
      def initialize(gateway)
        @gateway = gateway
      end

      def load_several(url)
        pag = @gateway.page(url)
        pag.map do |page_data|
          PageMapper.build_entity(page_data)
        end
      end

      def self.build_entity(page_data)
        DataMapper.new(page_data).build_entity
      end
    end

    # Extracts entity specific elements from data structure
    class DataMapper
      def initialize(page_data)
        @page = page_data
      end

      def build_entity(page_data)
        mapper = DataMap.new(page_data)

        Entity::Contributor.new(
          id: mapper.id,
          name: mapper.name,
          recipes_url: mapper.recipes_url
        )
      end

      private

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
      # def recipes
      #   @recipes ||= @data_source.recipes(recipes_url)
      # end
    end
  end
end
