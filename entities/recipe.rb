# frozen_string_literal: false

require 'date'

module RecipeBuddy
  # Module for Recipe
  module Entity
    # Domain entity object
    class Recipe
      attr_accessor :created_time, :content, :id, :full_picture, :reactions_like, :reactions_love, :reactions_wow, :reactions_haha, :reactions_sad, :reactions_angry

      def initialize(created_time: nil, content: nil, id: nil, full_picture: nil, reactions_like: nil, reactions_love: nil, reactions_wow: nil, reactions_haha: nil, reactions_sad: nil, reactions_angry: nil)
        @created_time = created_time
        @content = content
        @id = id
        @full_picture = full_picture
        @reactions_like = reactions_like
        @reactions_love = reactions_love
        @reactions_wow = reactions_wow
        @reactions_haha = reactions_haha
        @reactions_sad = reactions_sad
        @reactions_angry = reactions_angry
      end
    end
  end
end
