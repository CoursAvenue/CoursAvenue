class CreateDefaultRoomForPlacesThatDoesntHave < ActiveRecord::Migration
  def up
    Place.all.each do |place|
      if place.rooms.empty?
        place.rooms.create name: 'Salle principale'
      end
    end
  end

  def down
  end
end
