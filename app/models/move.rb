class Move < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :x, :y, presence: true
  validates :x, :y, inclusion: { in: 1..10, message: "должны быть в пределах от 1 до 10" }
  validate :cell_not_attacked_yet, on: :create

  private

  def cell_not_attacked_yet
    if Move.exists?(game_id: game_id, x: x, y: y)
      errors.add(:base, "В эту клетку уже стреляли")
    end
  end
end