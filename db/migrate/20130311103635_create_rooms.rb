class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :surface

      t.references :place
      t.timestamps
    end
  end
end
