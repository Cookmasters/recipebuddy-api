# frozen_string_literal: true

# Add Representer to module
module RecipeBuddy
  # Represents essential Video information for API output
  class VideoRepresenter < Roar::Decorator
    property :origin_id
    property :title
    property :published_at
    property :description
    property :channel_id
    property :channel_title
  end
end
