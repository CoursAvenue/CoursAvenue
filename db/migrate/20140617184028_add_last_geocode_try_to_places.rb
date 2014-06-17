class AddLastGeocodeTryToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :last_geocode_try, :datetime
  end
end
