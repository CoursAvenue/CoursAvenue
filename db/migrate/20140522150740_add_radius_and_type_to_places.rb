class AddRadiusAndTypeToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :type,   :string
    add_column :places, :radius, :integer
    Place.update_all type: 'Place::Public'
  end
end
