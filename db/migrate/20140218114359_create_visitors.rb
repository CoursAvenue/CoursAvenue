class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors do |t|
      t.integer :fingerprint

      t.timestamps
    end
  end
end
