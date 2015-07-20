class RenameMetroModuleToRatp < ActiveRecord::Migration
  def change
    rename_table :metro_stops,     :ratp_stops
    rename_table :metro_lines,     :ratp_lines
    rename_table :metro_positions, :ratp_positions
  end
end
