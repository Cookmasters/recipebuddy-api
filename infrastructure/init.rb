# frozen_string_literal: false

folders = %w[facebook youtube yummly database/orm]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
