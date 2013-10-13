class UpdatePlacesLocations < ActiveRecord::Migration
  def up
    bar = ProgressBar.new( Location.count )
    Location.all.each do |location|
      structure = Structure.friendly.find location.structure_id
      place     = Place.create(location: location, structure: structure)

      location_id = location.id
      Planning.where{place_id == location_id}.each do |planning|
        planning.update_column :place_id, place.id
      end
      bar.increment!
    end
  end

  def down
  end
end
