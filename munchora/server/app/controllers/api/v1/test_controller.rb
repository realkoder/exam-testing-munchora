class Api::V1::TestController < ApplicationController
  def test
    request.headers['test'] == 'test' ? (render json: { data: 'Test first branch' }) : (render json: { data: 'Test second branch' })
  end
end
