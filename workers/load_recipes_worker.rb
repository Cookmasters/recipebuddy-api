# frozen_string_literal: true

require_relative 'load_all'
require 'http'
require 'econfig'
require 'shoryuken'

# Shoryuken worker class to load the remaining recipes in parallel
class LoadRecipesWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  # require_relative 'test_helper' if ENV['RACK_ENV'] == 'test'

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: LoadRecipesWorker.config.AWS_ACCESS_KEY_ID,
    secret_access_key: LoadRecipesWorker.config.AWS_SECRET_ACCESS_KEY,
    region: LoadRecipesWorker.config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.WORKER_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, worker_request)
    page = get_data(worker_request)
    query = RecipeBuddy::Facebook::Api::Query.new(page.origin_id)
    remaining_recipes = RecipeBuddy::Facebook::RecipeMapper.new(
      LoadRecipesWorker.config
    ).load_several(query.recipes_next_page)[0]
    page_validator = RecipeBuddy::Entity::PageValidator.new(page)

    remaining_recipes.each do |recipe|
      next unless check_recipe(recipe)
      recipe.videos = page_validator.recipe_video_loader(
        recipe,
        LoadRecipesWorker.config
      )
      stored_recipe = RecipeBuddy::Repository::Recipes.find_or_create(
        recipe,
        page.id
      )
      publish(page.request_id, stored_recipe.id)
      puts "Recipe added with #{recipe.videos.count} videos"
    end
    # We rest the page request id
    RecipeBuddy::Repository::Pages.reset_request(page.id)
  end

  private

  def check_recipe(post)
    RecipeBuddy::Entity::RecipeChecker.new(post).recipe? &&
      RecipeBuddy::Repository::Recipes.find_origin_id(post.origin_id).nil?
  end

  def get_data(request)
    RecipeBuddy::PageRepresenter
      .new(OpenStruct.new)
      .from_json request
  end

  def publish(channel, message)
    puts 'Posting a recipe'
    HTTP.headers(content_type: 'application/json')
        .post(
          "#{LoadRecipesWorker.config.API_URL}/faye",
          body: {
            channel: "/#{channel}",
            data: message.to_json
          }.to_json
        )
  end
end
