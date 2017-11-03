# frozen_string_literal: false

folders = %w[facebook youtube database/orm]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
