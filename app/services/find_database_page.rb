# frozen_string_literal: true

require 'dry/transaction'

module RecipeBuddy
  # Transaction to load page from database
  class FindDatabasePage
    include Dry::Transaction

    step :find_page
    step :check_valid_page

    def find_page(input)
      page = Repository::For[Entity::Page]
             .find_name(input[:pagename])
      Right(page: page)
    rescue StandardError
      Left(Result.new(:internal_error, 'Could not access database'))
    end

    def check_valid_page(input)
      input_page = input[:page]
      if input_page
        Right(Result.new(:ok, input_page))
      else
        Left(Result.new(:not_found, 'Could not find stored page'))
      end
    end
  end
end
