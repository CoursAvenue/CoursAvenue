class RemoveLocationIdIndexOnPlaces < ActiveRecord::Migration
  def change
    remove_index :places, [:location_id, :structure_id]
    add_index :places, :structure_id
  end
end
