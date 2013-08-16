# encoding: utf-8
class MergeDuplicateLocations < ActiveRecord::Migration
  def up
    bar = ProgressBar.new (Location.count)
    Location.all.each do |location|
      location_street = location.street.gsub(',', '%').gsub(' ', '%').gsub('é', '%').gsub('è', '%').gsub('ê', '%').strip
      location_name   = location.name.gsub('é', '%').gsub('è', '%').gsub('ê', '%').strip
      if (duplicate_locations = Location.where{(name =~ location_name) & (street =~ location_street) & (latitude == location.latitude) & (longitude == location.longitude)}).length > 1
        duplicate_locations = duplicate_locations.reject{|l| l == location}
        duplicate_locations.each do |duplicate_location|
          duplicate_location.places do |place|
            place.update_column :location_id, location.id
          end
          puts "Deleting: #{duplicate_location.name}"
          duplicate_location.delete
        end
      end
      bar.increment!
    end
  end

  def down
  end
end
