class AddColumnsForGoogleMapsOnPlaces < ActiveRecord::Migration
  def change
    add_column :places, :latitude  , :float
    add_column :places, :longitude , :float
    add_column :places, :gmaps     , :boolean # not mandatory, see wiki
  end
end
