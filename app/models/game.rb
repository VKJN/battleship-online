class Game < ApplicationRecord
  has_many :ships, dependent: :destroy
  has_many :moves, dependent: :destroy

  # Случайная расстановка 4 кораблей (размерами 4, 3, 2, 1) для конкретного игрока
  def generate_fleet_for(user_id)
    occupied_cells = [] # Занятые клетки и буферная зона вокруг них

    [4, 3, 2, 1].each do |ship_size|
      loop do
        horizontal = [true, false].sample
        max_x = horizontal ? (11 - ship_size) : 10
        max_y = horizontal ? 10 : (11 - ship_size)

        start_x = rand(1..max_x)
        start_y = rand(1..max_y)

        # Собираем все клетки нового корабля
        new_ship_cells = (0...ship_size).map do |i|
          horizontal ? [start_x + i, start_y] : [start_x, start_y + i]
        end

        # Проверяем, не пересекается ли новый корабль с уже занятыми клетками и их окружением
        if (new_ship_cells & occupied_cells).empty?
          ships.create!(
            user_id: user_id,
            size: ship_size,
            start_x: start_x,
            start_y: start_y,
            horizontal: horizontal
          )

          # Добавляем сам корабль и все соседние клетки (включая диагонали) в список занятых
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

  # Вспомогательный метод: возвращает массив всех координат [x, y] кораблей игрока
  def fleet_coordinates_for(user_id)
    ships.where(user_id: user_id).flat_map do |ship|
      (0...ship.size).map do |i|
        ship.horizontal ? [ship.start_x + i, ship.start_y] : [ship.start_x, ship.start_y + i]
      end
    end
  end
end
