class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors do |t|
      t.integer :fingerprint

      t.timestamps
    end

    add_index :visitors, :fingerprint
  end
end
