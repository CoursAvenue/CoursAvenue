class AddingLocationFieldsToPlace < ActiveRecord::Migration
  def change
    add_column :places, :name, :string
    add_column :places, :latitude, :float
    add_column :places, :longitude, :float
    add_column :places, :street, :string
    add_column :places, :zip_code, :string
    add_column :places, :city_id, :integer
    add_column :places, :gmaps, :boolean

    bar = ProgressBar.new Place.count
    Place.find_each do |place|
      bar.increment!
      place.update_column(:name, place.name)
      place.update_column(:latitude, place.latitude)
      place.update_column(:longitude, place.longitude)
      place.update_column(:street, place.street)
      place.update_column(:zip_code, place.zip_code)
      place.update_column(:city_id, place.city_id)
      place.update_column(:gmaps, place.gmaps)
    end
  end
end
