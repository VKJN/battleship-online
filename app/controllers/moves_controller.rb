class MovesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    @game = Game.find(params[:game_id])
    
    result_status = ["cell-miss-dot", "cell-ship-damaged"].sample
    x_coord = params[:x].to_i
    y_coord = params[:y].to_i

    # Создаем ход в базе данных
    @move = @game.moves.create!(
      user_id: cookies[:user_id],
      x: x_coord,
      y: y_coord,
      status: result_status
    )

    # Отвечаем специальным потоком Turbo Stream
    respond_to do |format|
      format.turbo_stream do
        # Даём команду браузеру: замени элемент на новый обновлённый блок HTML
        render turbo_stream: turbo_stream.replace(
          "cell-#{x_coord}-#{y_coord}",
          helpers.content_tag(:div, "", id: "cell-#{x_coord}-#{y_coord}", class: "game-cell #{result_status}", style: "width: 100%; height: 100%; cursor: default;")
        )
      end
      # Запасной вариант, если сокеты заблокированы браузером
      format.html { redirect_to game_path(@game) }
    end
  end
end