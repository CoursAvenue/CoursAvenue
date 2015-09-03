class DropTableUnfinishedResources < ActiveRecord::Migration
  def change
    drop_table :unfinished_resources
  end
end
