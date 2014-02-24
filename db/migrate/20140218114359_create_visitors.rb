class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors do |t|
      add_index :visitors, :fingerprint

      t.integer :fingerprint

      t.timestamps
    end
  end
end
