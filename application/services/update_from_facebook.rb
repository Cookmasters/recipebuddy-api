# frozen_string_literal: true

require 'dry/transaction'

# Main module
module RecipeBuddy
  # Transaction to update the page recipes from Facebook
  class UpdateFromFacebook
    include Dry::Transaction

    step :check_if_page_exists
    step :update_page_recipes

    def check_if_page_exists(input)
      stored_page = Repository::For[Entity::Page].find_name(input[:pagename])
      if !stored_page
        Left(Result.new(:not_found, "This Facebook page doesn't exist"))
      else
        Right(page: stored_page, id: input[:id], config: input[:config])
      end
    end

    def update_page_recipes(input)
      page = input[:page]
      Repository::For[Entity::Recipe].delete_by_page(page.id)
      page.request_id = input[:id]
      page.recipes = []
      Repository::For[Entity::Page].update_request(page.id, page.request_id)
      stored_page = Repository::For[Entity::Page].update(page)
      puts page

      load_page_request = PageRepresenter.new(stored_page)
      LoadRecipesWorker.perform_async(load_page_request.to_json)
      Right(Result.new(:created, stored_page))
    # rescue StandardError => e
    #   puts e
    #   Left(Result.new(:internal_error,
    #                   'Could not store page fetched from Facebook'))
    end
  end
end
