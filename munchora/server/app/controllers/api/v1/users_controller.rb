class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :update, :destroy, :upload_image, :delete_image]

  # GET /api/v1/users?q=<search>&page=<amount>&per_page=<amount>
  def index
    users = User.all

    if params[:search].present?
      if params[:search].length > 120
        return render json: { error: 'Search query too long (max 120 characters)' }, status: :bad_request
      end

      query = "%#{params[:search].downcase}%" # Matches any string that contains search param and ignores case
      users = users.where(
        "LOWER(first_name || ' ' || last_name) LIKE ? OR LOWER(email) LIKE ?",
        query, query
      )
    end

    paginated_users = users.page(params[:page]).per(params[:per_page] || 10)

    render json: {
      data: paginated_users,
      pagination: {
        current_page: paginated_users.current_page,
        total_pages: paginated_users.total_pages,
        total_count: paginated_users.total_count
      }
    }
  end

  def show
    render json: current_user
  end

  def create
    if params[:user].blank?
      return render_error(400, 'Bad request', 'user parameter is required')
    end

    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if current_user.update(user_update_params)
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    if params[:id] != current_user.id
      return render json: { error: 'User could not be deleted' }, status: :unprocessable_content
    end

    if current_user.image_src.present?
      Users::UsersUploadsService.delete_old_image(user: current_user)
    end
    current_user.destroy
    if current_user.destroyed?
      render json: { msg: 'OK' }
    else
      render json: { msg: 'User could not be deleted' }, status: :unprocessable_content
    end
  end

  def upload_image
    result = Users::UsersUploadsService.call(user: current_user, uploaded_file: params[:image], request: request)

    if result.success?
      render json: { image_url: result.public_url }
    else
      render json: { error: result.error }, status: :unprocessable_content
    end
  end

  def delete_image
    if current_user
      if current_user.image_src.present?
        Users::UsersUploadsService.delete_old_image(user: current_user)
        current_user.update(image_src: nil)
        render json: { message: 'OK' }, status: :ok
      else
        render json: { error: 'No image to delete.' }, status: :unprocessable_content
      end
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  private

  def user_update_params
    params.require(:user).permit(:first_name, :last_name, :bio)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :bio, :password, :password_confirmation, :image_src, :provider, :uid)
  end
end
