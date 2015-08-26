class DropTableLivedPlaces < ActiveRecord::Migration
  def change
    drop_table :lived_places
  end
end
