class AddParentCityToCities < ActiveRecord::Migration
  def change
    add_column :cities, :parent_city_id, :integer
    add_index :cities, :parent_city_id
  end
end
