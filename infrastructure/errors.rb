# frozen_string_literal: false

module Errors
  # Not allowed to access resource
  Unauthorized = Class.new(StandardError)
  # Requested resource not found
  NotFound = Class.new(StandardError)
  # Bad request
  BadRequest = Class.new(StandardError)
  # Not allowed YUMMLY
  NotAllowed = Class.new(StandardError)
end
