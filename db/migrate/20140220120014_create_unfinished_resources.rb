class CreateUnfinishedResources < ActiveRecord::Migration
  def change
    create_table :unfinished_resources do |t|
      t.hstore :fields
      t.integer :visitor_id
      t.string :type

      t.timestamps
    end
  end
end
