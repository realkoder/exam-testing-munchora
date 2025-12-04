class Api::V1::TestController < ApplicationController
  def test
    request.headers['test'] == 'test' ? (render json: { data: 'hey' }) : (render json: { data: 'NOT hey' })
  end
end
