class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    @game = Game.create!(
      player_one_id: cookies[:user_id],
      current_turn_user_id: cookies[:user_id],
      status: "waiting"
    )
    # Расставляем случайный флот для первого игрока
    @game.generate_fleet_for(cookies[:user_id].to_i)

    redirect_to game_path(@game)
  end

  def join
    @game = Game.find(params[:id])
    current_user_id = cookies[:user_id].to_i

    if current_user_id > 0 && @game.player_one_id != current_user_id && @game.player_two_id.nil?
      @game.update!(player_two_id: current_user_id, status: "active")
      # Расставляем случайный флот для второго игрока
      @game.generate_fleet_for(current_user_id)
    end

    redirect_to game_path(@game)
  end

  def show
    @game = Game.find(params[:id])
    @current_user = User.find_by(id: cookies[:user_id])
    @moves = @game.moves
    # Получаем реальные координаты кораблей текущего игрока из БД
    @my_ships = @current_user ? @game.fleet_coordinates_for(@current_user.id) : []
  end
end
