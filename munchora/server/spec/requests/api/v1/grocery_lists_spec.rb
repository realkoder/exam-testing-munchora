require 'rails_helper'

RSpec.describe "Api::v1::GroceryLists", type: :request do
  describe "GET /index" do
    let(:user) { create(:user) }
    let(:token) { Auth::JsonWebToken.encode(user_id: user.id) }
    let(:other_user) { create(:user) }

    let!(:owned_list) { create(:grocery_list, owner: user, name: "Owned List") }
    let!(:shared_list) { create(:grocery_list, owner: other_user, name: "Shared List") }

    let!(:owned_item) { create(:grocery_list_item, grocery_list: owned_list, name: "Owned Item") }
    let!(:shared_item) { create(:grocery_list_item, grocery_list: shared_list, name: "Shared Item") }

    before do
      # Share the other_user's list with our user
      shared_list.shared_users << user
    end

    it "returns rejects without auth token" do
      get "/api/v1/grocery_lists"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns both owned and shared grocery lists" do
      cookies[:jwt_auth] = token
      get "/api/v1/grocery_lists"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.length).to eq(2)

      owned_json = json.find { |l| l["id"] == owned_list.id }
      expect(owned_json["name"]).to eq("Owned List")
      expect(owned_json["items"].first["name"]).to eq("Owned Item")
      expect(owned_json["shared_users"]).to eq([])

      shared_json = json.find { |l| l["id"] == shared_list.id }
      expect(shared_json["name"]).to eq("Shared List")
      expect(shared_json["items"].first["name"]).to eq("Shared Item")
      expect(shared_json["shared_users"].first["id"]).to eq(user.id)
    end
  end
end
