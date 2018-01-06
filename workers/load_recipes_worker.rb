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
    page = parse_worker_request(worker_request)
    query = RecipeBuddy::Facebook::Api::Query.new(page.origin_id, page.next)

    # Get remaining recipes
    url = get_recipes_url(page, query)

    recipes = fetch_recipes(url)

    # Parse and save the recipes
    parse_and_save_recipes(page, recipes)

    # We reset the page request id
    RecipeBuddy::Repository::Pages.reset_request(page.id)
  end

  private

  def get_recipes_url(page, query)
    page.next ? query.recipes_next_page : query.recipes_with_limit_url(100)
  end

  def fetch_recipes(query, config = LoadRecipesWorker.config)
    RecipeBuddy::Facebook::RecipeMapper.new(config).load_several(query)[0]
  end

  def parse_and_save_recipes(page, recipes)
    parsed_recipes = parse_recipes(recipes)
    save_recipes(page, parsed_recipes)
  end

  def parse_recipes(recipes)
    recipes.delete_if { |recipe| true unless check_recipe(recipe) }
    recipes.each do |recipe|
      checker = RecipeBuddy::Entity::RecipeChecker.new(recipe)
      checker.recipe?
      recipe.title = checker.recipe_title
    end
    recipes
  end

  def save_recipes(page, recipes, config = LoadRecipesWorker.config)
    page_validator = RecipeBuddy::Entity::PageValidator.new(page)
    recipes.each do |recipe|
      recipe.videos = page_validator.recipe_video_loader(recipe, config)
      stored_recipe = RecipeBuddy::Repository::Recipes.find_or_create(
        recipe,
        page.id
      )
      publish(page.request_id, stored_recipe.id)
    end
  end

  def check_recipe(post)
    RecipeBuddy::Entity::RecipeChecker.new(post).recipe? &&
      RecipeBuddy::Repository::Recipes.find_origin_id(post.origin_id).nil?
  end

  def parse_worker_request(request)
    RecipeBuddy::PageRepresenter
      .new(OpenStruct.new)
      .from_json request
  end

  def publish(channel, message)
    puts "Posting a recipe with ID: #{message}"
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
