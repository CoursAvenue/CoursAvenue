class AddIdToMetroLinesStops < ActiveRecord::Migration
  def change
    add_column :metro_lines_stops, :id, :integer
    add_index :metro_lines_stops, :id, unique: true
  end
end
