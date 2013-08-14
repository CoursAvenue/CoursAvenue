class AddJoinTableForPlaces < ActiveRecord::Migration
  def change
    rename_table :places, :locations

    create_table :places do |t|
      t.references :location, :structure
    end
    add_index :places, [:location_id, :structure_id]
  end
end
