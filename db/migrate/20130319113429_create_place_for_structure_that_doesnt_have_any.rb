class CreatePlaceForStructureThatDoesntHaveAny < ActiveRecord::Migration
  def up
    Structure.all.each do |structure|
      if structure.places.empty?
        if structure.city.nil?
          structure_zip_code = structure.zip_code
          structure.city = City.where{zip_code == structure_zip_code}.first
          structure.save
        end
        structure.places.create(
            name:       structure.name,
            street:     structure.street,
            zip_code:   structure.zip_code,
            city_id:    structure.city_id
          )
      end
    end
  end

  def down
  end
end
