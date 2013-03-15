class UpdateStructures < ActiveRecord::Migration
  def up
    Structure.all.each do |structure|
      place = structure.places.first
      if place
        structure.zip_code = place.zip_code
        structure.street   = place.street
        structure.city     = place.city
        structure.active   = true
        structure.save
      end
    end
  end

  def down
  end
end
