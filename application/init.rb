# frozen_string_literal: false

folders = %w[services representers controllers]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
