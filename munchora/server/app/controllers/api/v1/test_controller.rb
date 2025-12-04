class Api::V1::TestController < ApplicationController
  def test
    puts 'logged'
    request.headers['test'] == 'test' ? (render json: { data: 'hey' }) : (render json: { data: 'NOT hey' })
  end
end
