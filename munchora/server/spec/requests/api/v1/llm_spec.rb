require 'rails_helper'
require 'ostruct'

RSpec.describe Api::V1::LlmController, type: :request do
  let(:user) { create(:user, password: 'securepass') }
  let(:token) { Auth::JsonWebToken.encode(user_id: user.id) }

  # ======================================
  # POST: GENERATE_RECIPE
  # ======================================
  context '#generate_recipe' do
    let(:valid_prompt) { 'Something delicious!' }

    context 'positive tests' do
      before do
        allow_any_instance_of(Llm::LlmService).to receive(:usage_limit_exceeded?).and_return(false)

        mock_response = OpenStruct.new(choices: [OpenStruct.new(message: OpenStruct.new(content: "Generated recipe text"))])
        allow_any_instance_of(Llm::LlmService).to receive(:prompt_to_generate_recipe).with(anything).and_return(mock_response)

        allow_any_instance_of(Llm::LlmService).to receive(:validate_recipe_response).with(anything).and_return(build(:recipe))
      end

      it 'accepts authenticated requests' do
        cookies[:jwt_auth] = token
        post '/api/v1/llm/generate-recipe', params: { prompt: 'Something delicious' }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_response).to include(:title, :description, :ingredients, :user)
        expect(parsed_response[:ingredients]).to all(include(:name, :category, :amount))
        expect(parsed_response[:user]).to include(:id, :image_src)
      end
    end

    context 'negative tests' do
      it 'rejects unauthenticated requests' do
        post '/api/v1/llm/generate-recipe', params: { prompt: 'Something delicious' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # ======================================
  # PUT: UPDATE_RECIPE
  # ======================================
  context '#update_recipe' do
  end
end
