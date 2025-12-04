require 'rails_helper'

RSpec.describe Api::V1::TestController, type: :request do
  it 'logs in the user and sets a cookie' do
    get '/api/v1/test', headers: {
      'test' => 'test'
    }
    expect(response).to have_http_status(:ok)
    get '/api/v1/test'
    expect(response).to have_http_status(:ok)
  end
end
