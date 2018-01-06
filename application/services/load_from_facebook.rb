# frozen_string_literal: true

require 'dry/transaction'

# Main module
module RecipeBuddy
  # Transaction to load page from Facebook and save to database
  class LoadFromFacebook
    include Dry::Transaction

    step :get_page_from_facebook
    step :check_if_page_already_loaded
    step :check_if_is_recipes_page
    step :store_page_in_repository

    def get_page_from_facebook(input)
      page_url = input[:config].FACEBOOK_URL + input[:pagename]
      page = Facebook::PageMapper.new(input[:config])
                                 .find(page_url)
      Right(page: page, config: input[:config], id: input[:id])
    rescue StandardError
      Left(Result.new(:bad_request, 'Facebook page not found'))
    end

    def check_if_page_already_loaded(input)
      input_page = input[:page]
      if Repository::For[input_page.class].find(input_page)
        Left(Result.new(:conflict, 'Page already loaded from Facebook'))
      else
        Right(input)
      end
    end

    def check_if_is_recipes_page(input)
      page = input[:page]
      page_validator = Entity::PageValidator.new(page)
      if page_validator.recipes_page?
        page = page_validator.load_videos(input[:config])
        Right(page: page, id: input[:id])
      else
        Left(Result.new(:bad_request,
                        'This Facebook page does not contain enough recipes
                        to be added in our system! Please try another one.'))
      end
    end

    def store_page_in_repository(input)
      input_page = input[:page]
      input_page.request_id = input[:id]
      stored_page = Repository::For[input_page.class].create(input_page)
      load_page_request = PageRepresenter.new(stored_page)
      LoadRecipesWorker.perform_async(load_page_request.to_json)
      Right(Result.new(:created, stored_page))
    rescue StandardError => e
      puts e
      Left(Result.new(:internal_error,
                      'Could not store page fetched from Facebook'))
    end
  end
end
