class AddHasOnlyOnePlaceToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :has_only_one_place, :boolean
  end
end
