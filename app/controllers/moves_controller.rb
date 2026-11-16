class MovesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    @game = Game.find(params[:game_id])
    current_user_id = cookies[:user_id].to_i

    return head :forbidden unless @game.status == "active" && @game.current_turn_user_id == current_user_id

    x_coord = params[:x].to_i
    y_coord = params[:y].to_i

    opponent_id = (current_user_id == @game.player_one_id) ? @game.player_two_id : @game.player_one_id
    opponent_fleet = @game.fleet_coordinates_for(opponent_id)
    result_status = opponent_fleet.include?([x_coord, y_coord]) ? "cell-ship-damaged" : "cell-miss-dot"

    @move = @game.moves.new(
      user_id: current_user_id,
      x: x_coord,
      y: y_coord,
      status: result_status
    )

    if @move.save
      # Если попал — ход остаётся у стрелявшего, если промахнулся — переходит сопернику
      next_turn_id = (result_status == "cell-ship-damaged") ? current_user_id : opponent_id
      @game.update!(current_turn_user_id: next_turn_id)
      current_user = User.find(current_user_id)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "game_board_user_#{current_user_id}",
            partial: "games/board",
            locals: { game: @game, current_user: current_user }
          )
        end
        format.html { redirect_to game_path(@game) }
      end
    else
      head :unprocessable_entity
    end
  end
end