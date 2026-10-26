class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  
  # Метод создания новой игры
  def create
    @game = Game.create!(player_one_id: cookies[:user_id], status: "active")
    redirect_to game_path(@game)
  end

  # Метод показа экрана боя
  def show
    @game = Game.find(params[:id])
    @current_user = User.find_by(id: cookies[:user_id])
    @moves = @game.moves
  end
end
