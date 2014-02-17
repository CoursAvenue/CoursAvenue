class RemoveNbPlaceAvailableFromPlanning < ActiveRecord::Migration
  def up
    remove_column :plannings, :nb_place_available
  end
  def down
    add_column :plannings, :nb_place_available, :integer
  end
end
