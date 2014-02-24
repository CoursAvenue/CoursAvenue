class CreateUnfinishedResources < ActiveRecord::Migration
  def change
    create_table :unfinished_resources do |t|
      add_index :unfinished_resources, :visitor_id

      t.hstore :fields
      t.integer :visitor_id
      t.string :type

      t.timestamps
    end
  end
end
