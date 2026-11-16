class Game < ApplicationRecord
  has_many :ships, dependent: :destroy
  has_many :moves, dependent: :destroy

  # Отправляет обновлённую доску обоим игрокам по веб-сокетам без F5
  def broadcast_boards
    [player_one_id, player_two_id].compact.each do |uid|
      user = User.find_by(id: uid)
      next unless user

      broadcast_replace_to(
        self,
        target: "game_board_user_#{uid}",
        partial: "games/board",
        locals: { game: self, current_user: user }
      )
    end
  end

  def generate_fleet_for(user_id)
    occupied_cells = []

    [4, 3, 2, 1].each do |ship_size|
      loop do
        horizontal = [true, false].sample
        max_x = horizontal ? (11 - ship_size) : 10
        max_y = horizontal ? 10 : (11 - ship_size)

        start_x = rand(1..max_x)
        start_y = rand(1..max_y)

        new_ship_cells = (0...ship_size).map do |i|
          horizontal ? [start_x + i, start_y] : [start_x, start_y + i]
        end

        if (new_ship_cells & occupied_cells).empty?
          ships.create!(
            user_id: user_id,
            size: ship_size,
            start_x: start_x,
            start_y: start_y,
            horizontal: horizontal
          )

          new_ship_cells.each do |cx, cy|
            (-1..1).each do |dx|
              (-1..1).each do |dy|
                occupied_cells << [cx + dx, cy + dy]
              end
            end
          end

          break
        end
      end
    end
  end

  def fleet_coordinates_for(user_id)
    ships.where(user_id: user_id).flat_map do |ship|
      (0...ship.size).map do |i|
        ship.horizontal ? [ship.start_x + i, ship.start_y] : [ship.start_x, ship.start_y + i]
      end
    end
  end
end
