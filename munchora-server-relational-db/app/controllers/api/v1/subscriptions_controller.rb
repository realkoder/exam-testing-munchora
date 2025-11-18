class Api::V1::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: [:show, :cancel]

  # GET /subscriptions
  def index
    subscriptions = current_user.subscriptions
    render json: subscriptions, status: :ok
  end

  # GET /subscriptions/:id
  def show
    render json: @subscription, status: :ok
  end

  # POST /subscriptions
  def create
    subscription = current_user.subscriptions.new(subscription_params)
    subscription.status = 'active'

    if subscription.save
      render json: subscription, status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /subscriptions/:id/cancel
  def cancel
    if @subscription.update(status: 'cancelled', cancelled_at: Time.current)
      render json: @subscription, status: :ok
    else
      render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:subscription_plan_id)
  end
end
