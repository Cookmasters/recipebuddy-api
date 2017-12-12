# frozen_string_literal: true

require_relative 'load_all'

require 'econfig'
require 'shoryuken'

# Shoryuken worker class to load the remaining recipes in parallel
class LoadRecipesWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: LoadRecipesWorker.config.AWS_ACCESS_KEY_ID,
    secret_access_key: LoadRecipesWorker.config.AWS_SECRET_ACCESS_KEY,
    region: LoadRecipesWorker.config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.WORKER_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, worker_request)
    request = get_data(worker_request)
    query = RecipeBuddy::Facebook::Api::Query.new(request.origin_id)
    remaining_recipes = RecipeBuddy::Facebook::RecipeMapper.new(
      LoadRecipesWorker.config
    ).load_several(query.recipes_next_page)[0]
    updated_page = RecipeBuddy::Repository::Pages.update(
      all_recipes(request, remaining_recipes)
    )

    puts "Number of recipes at the end: #{updated_page.recipes.count}"
  end

  private

  def all_recipes(page, remaining_recipes)
    page.recipes = page.recipes + remaining_recipes
    page
  end

  def get_data(request)
    RecipeBuddy::PageRepresenter.new(OpenStruct.new)
                                .from_json request
  end
end
