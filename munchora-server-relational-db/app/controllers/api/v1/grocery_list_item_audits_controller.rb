class Api::V1::GroceryListItemAuditsController < ApplicationController
  before_action :authorize_admin!

  def index
    @grocery_list_item_audits = GroceryListItemAudit.all
    render json: @grocery_list_item_audits
  end
end
