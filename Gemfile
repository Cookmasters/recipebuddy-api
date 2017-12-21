# frozen_string_literal: false

source 'https://rubygems.org'
ruby '2.4.2'

# Networking gems
gem 'http'

# Asynchronicity gems
gem 'concurrent-ruby'

# Worker gems
gem 'aws-sdk-sqs', '~> 1'
gem 'faye', '~> 1'
gem 'shoryuken', '~> 3'

# Web app related
gem 'econfig'
gem 'pry' # to run migrations in production
gem 'puma'
gem 'rake' # to run migrations in production
gem 'roda'

# Database related
gem 'hirb'
gem 'sequel'

# Data gems
gem 'dry-struct'
gem 'dry-types'

# Representers
gem 'multi_json'
gem 'roar'

# Services
gem 'dry-monads'
gem 'dry-struct-setters'
gem 'dry-transaction'

# Testing gems
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

# Development gems
group :development, :test do
  gem 'sqlite3'

  gem 'database_cleaner'

  gem 'rerun'

  # Quality testing gems
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

group :production do
  gem 'pg'
end
