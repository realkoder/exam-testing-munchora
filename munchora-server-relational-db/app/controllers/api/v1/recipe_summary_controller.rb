class Api::V1::RecipeSummaryController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = RecipeSummaryView.order(total_likes: :desc).limit(20)
    render json: @recipes
  end
end
