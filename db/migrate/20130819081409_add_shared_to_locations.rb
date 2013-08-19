class AddSharedToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :shared, :boolean
  end
end
