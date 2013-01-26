class AddColumnsForGoogleMapsOnStructure < ActiveRecord::Migration
  def change
    add_column :structures, :latitude  , :float
    add_column :structures, :longitude , :float
    add_column :structures, :gmaps     , :boolean # not mandatory, see wiki
  end
end
