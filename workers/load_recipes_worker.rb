# frozen_string_literal: true

require_relative 'load_all'

require 'econfig'
require 'shoryuken'

# Shoryuken worker class to load the remaining recipes in parallel
class LoadRecipesWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))
  @@config = config


  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: @@config.AWS_ACCESS_KEY_ID,
    secret_access_key: @@config.AWS_SECRET_ACCESS_KEY,
    region: @@config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.WORKER_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, worker_request)
    request = RecipeBuddy::PageRepresenter.new(OpenStruct.new)
                                          .from_json worker_request

    # puts "REQUEST: #{request}"

    puts "Number of recipes in the beginning: #{request.recipes.count}"

    recipe_mapper = RecipeBuddy::Facebook::RecipeMapper.new(
      @@config
    )
    recipes_url = request.origin_id + recipes_base_url + \
                  recipes_reactions_positive_url + \
                  recipes_reactions_negative_url + \
                  recipes_next_url(request.next)
    remaining_recipes = recipe_mapper.load_several(recipes_url)[0]

    request.recipes.map! do |recipe|
      RecipeBuddy::Entity::Recipe.new(
        id: recipe.id,
        origin_id: recipe.origin_id,
        title: recipe.title,
        created_time: DateTime.parse(recipe.created_time),
        content: recipe.content,
        full_picture: recipe.full_picture,
        reactions_like: recipe.reactions_like,
        reactions_love: recipe.reactions_love,
        reactions_wow: recipe.reactions_wow,
        reactions_haha: recipe.reactions_haha,
        reactions_sad: recipe.reactions_sad,
        reactions_angry: recipe.reactions_angry,
        videos: videos(recipe)
      )
    end

    all_recipes = request.recipes + remaining_recipes
    request.recipes = all_recipes
    updated_page = RecipeBuddy::Repository::Pages.update(request)

    puts "Number of recipes at the end: #{updated_page.recipes.count}"
  end

  def recipes_base_url
    '/posts?fields=full_picture,created_time,message'
  end

  def recipes_reactions_positive_url
    ',reactions.type(LIKE).limit(0).summary(total_count)'\
    '.as(reactions_like)'\
    ',reactions.type(LOVE).limit(0).summary(total_count)'\
    '.as(reactions_love)'\
    ',reactions.type(WOW).limit(0).summary(total_count)'\
    '.as(reactions_wow)'\
    ',reactions.type(HAHA).limit(0).summary(total_count)'\
    '.as(reactions_haha)'
  end

  def recipes_reactions_negative_url
    ',reactions.type(SAD).limit(0).summary(total_count)'\
    '.as(reactions_sad)'\
    ',reactions.type(ANGRY).limit(0).summary(total_count)'\
    '.as(reactions_angry)'
  end

  def recipes_next_url(token)
    "&limit=100&after=#{token}"
  end

  def videos(recipe)
    recipe.videos.map do |video|
      RecipeBuddy::Entity::Video.new(
        id: video.id, origin_id: video.origin_id,
        title: video.title,
        published_at: DateTime.parse(video.published_at),
        description: video.description,
        channel_id: video.channel_id,
        channel_title: video.channel_title
      )
    end
  end
end
