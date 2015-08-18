class CreateStructureDuplicates < ActiveRecord::Migration
  def change
    create_table :structure_duplicate_lists do |t|
      t.references :structure, index: true
      t.hstore :metadata

      t.timestamps
    end
  end
end
