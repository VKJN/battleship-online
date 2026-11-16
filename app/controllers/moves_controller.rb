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
      @game.update!(current_turn_user_id: opponent_id)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "cell-#{x_coord}-#{y_coord}",
              helpers.content_tag(:div, "", id: "cell-#{x_coord}-#{y_coord}", class: "game-cell #{result_status}", style: "width: 100%; height: 100%; cursor: default;")
            ),
            turbo_stream.replace(
              "turn-indicator",
              helpers.content_tag(:div, "⏳ Ход соперника! Нажмите F5, когда он походит", id: "turn-indicator", style: "color: #ffb700; font-weight: bold; font-size: 1.1rem;")
            )
          ]
        end
        format.html { redirect_to game_path(@game) }
      end
    else
      head :unprocessable_entity
    end
  end
end
