class Api::V1::UserAuditsController < ApplicationController
  before_action :authorize_admin!

  def index
    @user_audits = UserAudit.all
    render json: @user_audits
  end
end
