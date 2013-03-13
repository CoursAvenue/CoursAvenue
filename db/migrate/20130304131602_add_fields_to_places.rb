class AddFieldsToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :has_cloackroom, :boolean, default: false
    add_column :places, :has_internet, :boolean, default: false
    add_column :places, :has_air_conditioning, :boolean, default: false
    add_column :places, :has_swimming_pool, :boolean, default: false
    add_column :places, :has_free_parking, :boolean, default: false
    add_column :places, :has_jacuzzi, :boolean, default: false
    add_column :places, :has_sauna, :boolean, default: false
    add_column :places, :has_daylight, :boolean, default: false
  end
end
