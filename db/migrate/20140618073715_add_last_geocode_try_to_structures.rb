class AddLastGeocodeTryToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :last_geocode_try, :datetime
  end
end
