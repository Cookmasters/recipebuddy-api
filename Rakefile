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

desc 'rerun tests'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
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
  CODE = 'infrastructure/'.freeze
  folders = %i[app domain infrastructure]

  desc 'run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh 'rubocop'
  end

  task :reek do
    folders.each do |folder|
      sh "reek #{folder}"
    end
  end

  task :flog do
    folders.each do |folder|
      sh "flog #{folder}"
    end
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
