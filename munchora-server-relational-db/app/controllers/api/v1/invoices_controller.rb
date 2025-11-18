class Api::V1::InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: [:show, :pay]

  # GET /invoices
  def index
    invoices = current_user.invoices.order(created_at: :desc)
    render json: invoices, status: :ok
  end

  # GET /invoices/:id
  def show
    render json: @invoice, status: :ok
  end

  # POST /invoices/:id/pay
  def pay
    # This is where you'd integrate with a payment gateway
    if @invoice.update(status: 'paid', paid_at: Time.current)
      render json: @invoice, status: :ok
    else
      render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_invoice
    @invoice = current_user.invoices.find(params[:id])
  end
end
