# frozen_string_literal: true

folders = %w[config infrastructure domain representers app]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
