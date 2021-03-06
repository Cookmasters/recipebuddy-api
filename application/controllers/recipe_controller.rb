# frozen_string_literal: true

require 'roda'

module RecipeBuddy
  # Web API
  class Api < Roda
    plugin :all_verbs

    # #{API_ROOT}/recipe branch
    route('recipe') do |routing|
      # GET #{API_ROOT}/recipe/best request
      routing.on 'best' do
        routing.get do
          recipes = Repository::For[Entity::Recipe].best
          RecipesRepresenter.new(Recipes.new(recipes)).to_json
        end
      end

      # GET #{API_ROOT}/recipe/all request
      routing.on 'all' do
        routing.get do
          recipes = Repository::For[Entity::Recipe].all
          RecipesRepresenter.new(Recipes.new(recipes)).to_json
        end
      end

      # GET #{API_ROOT}/recipe/search/:keyword request
      routing.on 'search' do
        routing.get String do |keyword|
          recipes = Repository::For[Entity::Recipe].search(keyword)
          RecipesRepresenter.new(Recipes.new(recipes)).to_json
        end
      end

      # #{API_ROOT}/recipe/:id branch
      routing.on Integer do |id|
        # GET #{API_ROOT}/recipe/:id request
        routing.get do
          find_result = FindDatabaseRecipe.call(id: id)
          represent_response(find_result, RecipeRepresenter)
        end
      end

      # DELETE #{API_ROOT}/recipe request
      Api.configure :development, :test do
        routing.delete do
          %i[videos recipes pages].each { |table| Api.db[table].delete }
          http_response = HttpResponseRepresenter
                          .new(Result.new(:ok, 'deleted tables'))
          response.status = http_response.http_code
          http_response.to_json
        end
      end
    end
  end
end
