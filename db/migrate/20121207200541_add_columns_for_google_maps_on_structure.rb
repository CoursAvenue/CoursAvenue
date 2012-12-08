class AddColumnsForGoogleMapsOnStructure < ActiveRecord::Migration
  def up
    add_column :structures, :latitude  , :float
    add_column :structures, :longitude , :float
    add_column :structures, :gmaps     , :boolean # not mandatory, see wiki
  end

  def down
    remove_column :structures, :latitude  , :float
    remove_column :structures, :longitude , :float
    remove_column :structures, :gmaps     , :boolean # not mandatory, see wiki
  end
end
