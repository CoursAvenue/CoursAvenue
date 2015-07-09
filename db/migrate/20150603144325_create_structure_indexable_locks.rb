class CreateStructureIndexableLocks < ActiveRecord::Migration
  def change
    create_table :structure_indexable_locks do |t|
      t.references :structure, index: true
      t.datetime :locked_at
      t.boolean :locked, default: false

      t.timestamps
    end
  end
end
