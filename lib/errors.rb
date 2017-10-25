# frozen_string_literal: false

module RecipeBuddy
  # Provides access to page dataAccess to FacebookApi
  module Errors
    # Not allowed to access resource
    Unauthorized = Class.new(StandardError)
    # Requested resource not found
    NotFound = Class.new(StandardError)
    # Bad request
    BadRequest = Class.new(StandardError)
  end
end
