class Api::V1::RecipeSuggestionsController < ApplicationController
  before_action :authenticate_user! # ensures user is logged in
  def index
    suggestions = current_user.recipe_suggestions.includes(:recipe).order(created_at: :desc)

    render json: suggestions.as_json(
      include: {
        recipe: {
          only: [:id, :title, :description, :image_url, :prep_time, :cook_time, :servings]
        }
      },
      only: [:id, :created_at]
    ), status: :ok
  end
end
