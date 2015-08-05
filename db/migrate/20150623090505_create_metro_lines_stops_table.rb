class CreateMetroLinesStopsTable < ActiveRecord::Migration
  def change
    create_table :metro_lines_stops, id: false do |t|
      t.integer :line_id
      t.integer :stop_id
    end

    add_index :metro_lines_stops, [:line_id, :stop_id], unique: true
  end
end
