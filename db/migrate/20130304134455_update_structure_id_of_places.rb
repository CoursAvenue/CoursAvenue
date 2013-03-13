class UpdateStructureIdOfPlaces < ActiveRecord::Migration
  def up
    Place.all.each do |place|
      place.structure_id = place.courses.first.structure_id unless place.courses.empty?
      place.save
    end
  end

  def down
  end
end
