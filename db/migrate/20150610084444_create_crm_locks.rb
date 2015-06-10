class CreateCrmLocks < ActiveRecord::Migration
  def change
    create_table :crm_locks do |t|
      t.boolean :locked
      t.datetime :locked_at
      t.references :structure

      t.timestamps
    end
  end
end
