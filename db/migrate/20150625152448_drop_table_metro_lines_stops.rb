class DropTableMetroLinesStops < ActiveRecord::Migration
  def change
    drop_table :metro_lines_stops
  end
end
