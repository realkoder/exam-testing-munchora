class Api::V1::TestController < ApplicationController
  def test
    puts 'logged'
    # render json: { data: "hey" }
    arr = []
    100.times do
      arr << Object.methods.sample
    end
    render json: arr
  end
end
