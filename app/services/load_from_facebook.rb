# frozen_string_literal: true

require 'dry/transaction'

module RecipeBuddy
  # Transaction to load page from Facebook and save to database
  class LoadFromFacebook
    include Dry::Transaction

    step :get_page_from_facebook
    step :check_if_page_already_loaded
    step :store_page_in_repository

    def get_page_from_facebook(input)
      page = Facebook::PageMapper.new(input[:config])
                                 .find(input[:pagename])
      Right(page: page)
    rescue StandardError
      Left(Result.new(:bad_request, 'Facebook page not found'))
    end

    def check_if_page_already_loaded(input)
      input_page = input[:page]
      if Repository::For[input_page.class].find(input_page)
        Left(Result.new(:conflict, 'Page already fetched from Facebook'))
      else
        Right(input)
      end
    end

    def store_page_in_repository(input)
      input_page = input[:page]
      stored_page = Repository::For[input_page.class].create(input_page)
      Right(Result.new(:created, stored_page))
    rescue StandardError
      Left(Result.new(:internal_error,
                      'Could not store page fetched from Facebook'))
    end
  end
end
