class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.integer :structure_id
      t.integer :user_id

      t.timestamps
    end
    add_index :followings, [:user_id, :structure_id]
  end
end
