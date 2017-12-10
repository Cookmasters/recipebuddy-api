# frozen_string_literal: true

folders = %w[config infrastructure domain application worker]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
