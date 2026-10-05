class CreateShips < ActiveRecord::Migration[8.1]
  def change
    create_table :ships do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :size
      t.integer :start_x
      t.integer :start_y
      t.boolean :horizontal

      t.timestamps
    end
  end
end
