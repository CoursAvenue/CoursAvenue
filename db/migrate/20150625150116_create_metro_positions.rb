class CreateMetroPositions < ActiveRecord::Migration
  def change
    create_table :metro_positions do |t|
      t.references :metro_line, index: true
      t.references :metro_stop, index: true
      t.integer :position

      t.index [:metro_line_id, :metro_stop_id], unique: true

      t.timestamps
    end
  end
end
