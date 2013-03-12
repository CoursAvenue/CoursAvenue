class AddCityIdToStructureAndRemoveCityName < ActiveRecord::Migration
  def change
    add_column :structures, :city_id, :integer
    remove_column :structures, :city_name
  end
end
