class AddCurrentTurnToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :current_turn_user_id, :integer
  end
end
