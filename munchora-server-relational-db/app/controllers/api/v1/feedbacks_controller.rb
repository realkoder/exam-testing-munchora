class Api::V1::FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :destroy]
  before_action :authorize_admin!, only: [:index, :show, :destroy]

  # GET /api/v1/feedbacks?&page=<amount>&per_page=<amount>
  def index
    feedback = Feedback.order(created_at: :desc)
    paginated_feedback = feedback.page(params[:page]).per(params[:per_page] || 10)

    render json: {
      data: paginated_feedback,
      pagination: {
        current_page: paginated_feedback.current_page,
        total_pages: paginated_feedback.total_pages,
        total_count: paginated_feedback.total_count
      }
    }
  end

  # GET /api/v1/feedbacks/:id
  def show
    render json: @feedback
  end

  # POST /api/v1/feedbacks
  def create
    feedback = Feedback.new(feedback_params)
    if feedback.save
      render json: { message: 'Feedback submitted successfully.' }, status: :created
    else
      render json: { errors: feedback.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/feedbacks/:id
  def destroy
    @feedback.destroy
    head :no_content
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Feedback not found' }, status: :not_found
  end

  def feedback_params
    params.require(:feedback).permit(:name, :email, :category, :message)
  end
end
