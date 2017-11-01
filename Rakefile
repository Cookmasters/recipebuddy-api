# frozen_string_literal: false

require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'run tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

task :console do
  sh 'pry -r ./spec/test_load_all'
end

desc 'delete cassette fixtures'
task :rmvcr do
  sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
    puts(ok ? 'Cassettes deleted' : 'No cassettes found')
  end
end

namespace :quality do
  CODE = 'lib/'.freeze

  desc 'run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh 'rubocop'
  end

  task :reek do
    sh "reek #{CODE}"
  end

  task :flog do
    sh "flog #{CODE}"
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
      Sequel::Migrator.run(app.DB, 'infrastructure/database/migrations')
    end

    desc 'Drop all tables'
    task :drop do
      require_relative 'config/environment.rb'
      # drop according to dependencies
      app.DB.drop_table :pages
      app.DB.drop_table :recipes
      app.DB.drop_table :videos
      app.DB.drop_table :schema_info
    end

    desc 'Reset all database tables'
    task reset: [:drop, :migrate]

    desc 'Delete dev or test database file'
    task :wipe do
      if app.environment == :production
        puts 'Cannot wipe production database!'
        return
      end

      FileUtils.rm(app.config.db_filename)
      puts "Deleted #{app.config.db_filename}"
    end
  end
end
