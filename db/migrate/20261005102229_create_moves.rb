class CreateMoves < ActiveRecord::Migration[8.1]
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :x
      t.integer :y
      t.string :status

      t.timestamps
    end
  end
end
