class AddCityIdToStructureAndRemoveCityName < ActiveRecord::Migration
  def change
    add_column :structures, :city_id, :integer
  end
end
