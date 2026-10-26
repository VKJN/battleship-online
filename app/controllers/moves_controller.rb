class MovesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    @game = Game.find(params[:game_id])
    
    # Случайным образом определяем статус
    result_status = ["cell-miss-dot", "cell-ship-damaged"].sample

    # Создаем ход в базе с пришедшими координатами X и Y
    @game.moves.create!(
      user_id: cookies[:user_id],
      x: params[:x],
      y: params[:y],
      status: result_status
    )

    # Возвращаем игрока обратно на экран боя, чтобы увидеть обновленную карту
    redirect_to game_path(@game)
  end
end
