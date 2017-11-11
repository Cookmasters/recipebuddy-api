# frozen_string_literal: true

require_relative 'video_representer'

# Add Representer to module
module RecipeBuddy
  # Represents essential Recipe information for API output
  class RecipeRepresenter < Roar::Decorator
    include Roar::JSON
    property :origin_id
    property :created_time
    property :content
    property :full_picture
    property :reactions_like
    property :reactions_love
    property :reactions_wow
    property :reactions_haha
    property :reactions_sad
    property :reactions_angry
    collection :videos, extend: Video_Representer
  end
end
