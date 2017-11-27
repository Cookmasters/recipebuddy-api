# frozen_string_literal: true

require 'dry/transaction'
require 'uri'

module RecipeBuddy
  # Transaction to load page from Facebook and save to database
  class LoadFromFacebook
    include Dry::Transaction

    step :get_page_from_facebook
    step :check_if_page_already_loaded
    step :check_if_is_recipes_page
    step :store_page_in_repository

    def get_page_from_facebook(input)
      page_url = input[:config].FACEBOOK_URL + input[:pagename]
      page = Facebook::PageMapper.new(input[:config])
                                 .find(page_url)
      Right(page: page, config: input[:config])
    rescue StandardError => e
      puts e
      Left(Result.new(:bad_request, 'Facebook page not found'))
    end

    def check_if_page_already_loaded(input)
      input_page = input[:page]
      if Repository::For[input_page.class].find(input_page)
        Left(Result.new(:conflict, 'Page already loaded from Facebook'))
      else
        Right(input)
      end
    end

    def check_if_is_recipes_page(input)
      page = input[:page]
      posts_count = page.recipes.count
      recipes_count = 0.0
      not_recipes_list = []
      page.recipes.each do |post|
        is_recipe = recipe?(post)
        recipes_count += 1 if is_recipe
        not_recipes_list << post.origin_id unless is_recipe
      end
      percentage = recipes_count / posts_count
      page.recipes.delete_if do |item|
        true if not_recipes_list.include?(item.origin_id)
      end
      if percentage <= 0.5
        Left(Result.new(:bad_request,
                        'This Facebook page does not contain enough recipes \
                        to be added in our system! Please try another one.'))
      else
        page.recipes.map do |recipe|
          recipe_title = URI.encode_www_form([['q', recipe.title]])
          videos_url = "search?#{recipe_title}"
          videos = Youtube::VideoMapper.new(input[:config])
                                       .load_several(videos_url)
          recipe.videos = videos
        end
        Right(input)
      end
    end

    def store_page_in_repository(input)
      input_page = input[:page]
      stored_page = Repository::For[input_page.class].create(input_page)
      Right(Result.new(:created, stored_page))
    rescue StandardError
      Left(Result.new(:internal_error,
                      'Could not store page fetched from Facebook'))
    end

    def recipe?(post)
      content = post.content
      return false unless content
      count_is_recipe = 0
      content.each_line do |line|
        count_is_recipe = 0 unless numeric?(line[0])
        count_is_recipe += 1 if numeric?(line[0])
        break if count_is_recipe >= 3
      end
      count_is_recipe >= 3
    end

    def numeric?(str)
      Integer(str)
      true
    rescue StandardError
      false
    end
  end
end
