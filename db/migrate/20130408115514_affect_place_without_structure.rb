class AffectPlaceWithoutStructure < ActiveRecord::Migration
  def up
    Place.where{structure_id == nil}.each do |place|
      place_name = place.name
      if (structure = Structure.where{name == place_name}.first)
        place.update_column :structure_id, structure.id
      end
    end
  end

  def down
  end
end
