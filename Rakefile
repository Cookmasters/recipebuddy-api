# frozen_string_literal: false

require 'rake/testtask'

task :default do
  puts `rake -T`
end

# Configuration only -- not for direct calls
task :config do
  require_relative 'config/environment.rb' # load config info
  @app = RecipeBuddy::Api
  @config = @app.config
end

desc 'run tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'rerun tests'
task :respec do
  puts 'REMEMBER: need to run `rake run:[dev|test]:worker` in another process'
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'run application console (pry)'
task :console do
  sh 'pry -r ./spec/test_load_all'
end

namespace :run do
  namespace :api do
    task :dev => :config do
      puts 'REMEMBER: need to run `rake run:dev:worker` in another process'
      sh "rerun -c 'rackup -p 3030' --ignore 'coverage/*'"
    end

    task :test => :config do
      puts 'REMEMBER: need to run `rake run:test:worker` in another process'
      sh "rerun -c 'RACK_ENV=test rackup -p 3000' --ignore 'coverage/*'"
    end
  end
  namespace :worker do
    task :dev => :config do
      sh 'bundle exec shoryuken -r ./workers/load_recipes_worker.rb -C ./workers/shoryuken.yml'
    end

    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/load_recipes_worker.rb -C ./workers/shoryuken_test.yml'
    end
  end
end

desc 'delete cassette fixtures'
task :rmvcr do
  sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
    puts(ok ? 'Cassettes deleted' : 'No cassettes found')
  end
end

namespace :quality do
  CODE = '**/*.rb'.freeze

  desc 'run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh "rubocop #{CODE}"
  end

  task :reek do
    sh "reek #{CODE}"
  end

  task :flog do
    sh "flog #{CODE}"
  end
end

# Database tasks
namespace :db do
  require_relative 'config/environment.rb' # load config info
  require 'sequel' # TODO: remove after create orm

  Sequel.extension :migration
  app = RecipeBuddy::Api

  desc 'Run migrations'
  task :migrate do
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.db, 'infrastructure/database/migrations')
  end

  desc 'Drop all tables'
  task :drop do
    require_relative 'config/environment.rb'
    # drop according to dependencies
    app.db.drop_table :videos
    app.db.drop_table :recipes
    app.db.drop_table :pages
    app.db.drop_table :schema_info
  end

  desc 'Reset all database tables'
  task reset: %i[drop migrate]

  desc 'Delete dev or test database file'
  task :wipe do
    return nil unless app.environment != :production

    FileUtils.rm(app.config.DB_FILENAME)
    puts "Deleted #{app.config.DB_FILENAME}"
  end
end

namespace :queue do
  require 'aws-sdk-sqs'

  desc 'Create SQS queue for Shoryuken'
  task :create => :config do
    sqs = Aws::SQS::Client.new(
      access_key_id: @config.AWS_ACCESS_KEY_ID,
      secret_access_key: @config.AWS_SECRET_ACCESS_KEY,
      region: @config.AWS_REGION
    )

    begin
      sqs.create_queue(
        queue_name: @config.WORKER_QUEUE,
        attributes: {
          FifoQueue: 'true',
          ContentBasedDeduplication: 'true'
        }
      )

      q_url = sqs.get_queue_url(queue_name: @config.WORKER_QUEUE)
      puts 'Queue created:'
      puts "Name: #{@config.WORKER_QUEUE}"
      puts "Region: #{@config.AWS_REGION}"
      puts "URL: #{q_url.queue_url}"
      puts "Environment: #{@app.environment}"
    rescue StandardError => e
      puts "Error creating queue: #{e}"
    end
  end

  task :purge => :config do
    sqs = Aws::SQS::Client.new(
      access_key_id: @config.AWS_ACCESS_KEY_ID,
      secret_access_key: @config.AWS_SECRET_ACCESS_KEY,
      region: @config.AWS_REGION
    )

    begin
      sqs.purge_queue(queue_url: @config.WORKER_QUEUE_URL)
      puts "Queue #{@config.WORKER_QUEUE} purged"
    rescue StandardError => e
      puts "Error purging queue: #{e}"
    end
  end
end
