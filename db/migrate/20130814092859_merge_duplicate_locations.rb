class MergeDuplicateLocations < ActiveRecord::Migration
  def up
    bar = ProgressBar.new (Location.count)
    Location.all.each do |location|
      if (duplicate_locations = Location.where{(name == location.name) & (street == location.street) & (latitude == location.latitude) & (longitude == location.longitude)}).length > 1
        duplicate_locations = duplicate_locations.reject{|l| l == location}
        duplicate_locations.each do |duplicate_location|
          duplicate_location.places do |place|
            place.update_column :location_id, location.id
          end
          duplicate_location.delete
        end
      end
      bar.increment!
    end
  end

  def down
  end
end
