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
      place.update_column(:name, place.location.name)
      place.update_column(:latitude, place.location.latitude)
      place.update_column(:longitude, place.location.longitude)
      place.update_column(:street, place.location.street)
      place.update_column(:zip_code, place.location.zip_code)
      place.update_column(:city_id, place.location.city_id)
      place.update_column(:gmaps, place.location.gmaps)
    end
  end
end
