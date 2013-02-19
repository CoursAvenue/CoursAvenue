class RemovePlacesStructuresJoinTable < ActiveRecord::Migration
  def up
    drop_table :places_structures
  end

  def down
    create_table :places_structures, :id => false do |t|
      t.references :place, :structure
    end
    add_index :places_structures, [:place_id, :structure_id]
  end
end
