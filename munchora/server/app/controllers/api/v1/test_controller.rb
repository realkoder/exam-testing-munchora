class Api::V1::TestController < ApplicationController
  def test
    request.headers['test'] == 'test' ? (render json: { data: 'Test returning from first branch' }) : (render json: { data: 'Test returning from second branch' })
  end
end
